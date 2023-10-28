import SwiftSyntax
import SwiftSyntaxBuilder

struct JSFactory {
    private let variablesImplementationFactory = VariablesImplementationFactory()
    private let functionImplementationFactory = FunctionImplementationFactory()

    func classDeclaration(for protocolDeclaration: ProtocolDeclSyntax) throws -> ClassDeclSyntax {
        let identifier = TokenSyntax.identifier(protocolDeclaration.name.text + "JSBridge")
        let variableDeclarations = protocolDeclaration.memberBlock.members.compactMap { $0.decl.as(VariableDeclSyntax.self) }
        let functionDeclarations = protocolDeclaration.memberBlock.members.compactMap { $0.decl.as(FunctionDeclSyntax.self) }

        return try ClassDeclSyntax(name: .identifier(identifier.text),
                                   inheritanceClause: InheritanceClauseSyntax { InheritedTypeSyntax(type: IdentifierTypeSyntax(name: protocolDeclaration.name)) },
                                   memberBlock: .init(membersBuilder: {
            DeclSyntax(stringLiteral: helperTemplate)

            for variableDeclaration in variableDeclarations {
                try variablesImplementationFactory.variablesDeclarations(protocolVariableDeclaration: variableDeclaration)
            }

            for functionDeclaration in functionDeclarations {
                try functionImplementationFactory.declaration(protocolFunctionDeclaration: functionDeclaration)
            }
        }))
    }
}
