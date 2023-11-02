import SwiftSyntax
import SwiftSyntaxBuilder

struct VariablesImplementationFactory {
    @MemberBlockItemListBuilder
    func variablesDeclarations(protocolVariableDeclaration: VariableDeclSyntax) throws -> MemberBlockItemListSyntax {
        if let binding = protocolVariableDeclaration.bindings.first {
            try protocolVariableDeclarationWithGetterAndSetter(binding: binding)

            let identifierText = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text ?? ""
            let identifierType = identifierType(binding: binding)

            DeclSyntax(stringLiteral: """
            func set\(identifierText.prefix(1).uppercased() + identifierText.dropFirst())(_ value:\(identifierType)) throws {
                let jsValue = try encoder.encode(value, in: jsContext)
                jsContext.setObject(jsValue, forKeyedSubscript: "\(identifierText)" as (NSCopying & NSObjectProtocol)?)
            }
            """)
        }
    }

    private func protocolVariableDeclarationWithGetterAndSetter(binding: PatternBindingListSyntax.Element) throws -> DeclSyntaxProtocol {
        let identifierText = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text ?? ""
        let identifierType = identifierType(binding: binding)
        let throwsSpecifier = binding.as(PatternBindingSyntax.self)?.accessorBlock?.accessors.as(AccessorDeclListSyntax.self)?.first?.effectSpecifiers?.throwsSpecifier?.text

        if throwsSpecifier != "throws" {
            throw SwiftyJSDiagnostic.variablesGetterMustBeThrowable
        }

        return VariableDeclSyntax(
            bindingSpecifier: .keyword(.var),
            bindingsBuilder: {
                PatternBindingSyntax(
                    pattern: binding.pattern,
                    typeAnnotation: binding.typeAnnotation,
                    accessorBlock: AccessorBlockSyntax(
                        accessors: .accessors(
                            AccessorDeclListSyntax {
                                AccessorDeclListSyntax(arrayLiteral:
                              """
                              get throws {
                                guard let result = jsContext.objectForKeyedSubscript("\(raw: identifierText)") else {
                                    throw error("JSValue couldn't retrieve")
                                }
                                return try decoder.decode(\(raw: identifierType).self, from: result)
                              }
                              """
                                )
                            }
                        )
                    )
                )
            }
        )
    }

    private func identifierType(binding: PatternBindingListSyntax.Element) -> String {
        if let identifierType = binding.as(PatternBindingSyntax.self)?.typeAnnotation?.type.as(OptionalTypeSyntax.self)?.wrappedType.as(IdentifierTypeSyntax.self)?.name.text {
            return identifierType + "?"
        }
        
        if let identifierType = binding.as(PatternBindingSyntax.self)?.typeAnnotation?.type.as(IdentifierTypeSyntax.self)?.name.text {
            return identifierType
        }

        if let identifierType = binding.as(PatternBindingSyntax.self)?.typeAnnotation?.type.as(ArrayTypeSyntax.self)?.element.as(IdentifierTypeSyntax.self)?.name.text {
            return "[\(identifierType)]"
        }

        if let identifierType = binding.as(PatternBindingSyntax.self)?.typeAnnotation?.type.as(ArrayTypeSyntax.self)?.element.as(OptionalTypeSyntax.self)?.wrappedType.as(IdentifierTypeSyntax.self)?.name.text {
            return "[\(identifierType)?]"
        }

        return ""
    }
}
