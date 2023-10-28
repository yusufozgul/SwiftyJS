import SwiftSyntax
import SwiftSyntaxBuilder

struct FunctionImplementationFactory {
    func declaration(protocolFunctionDeclaration: FunctionDeclSyntax) throws -> FunctionDeclSyntax {
        try FunctionDeclSyntax.init(attributes: protocolFunctionDeclaration.attributes,
                                    modifiers: protocolFunctionDeclaration.modifiers,
                                    funcKeyword: protocolFunctionDeclaration.funcKeyword,
                                    name: .identifier(protocolFunctionDeclaration.name.text),
                                    genericParameterClause: protocolFunctionDeclaration.genericParameterClause,
                                    signature: protocolFunctionDeclaration.signature,
                                    genericWhereClause: protocolFunctionDeclaration.genericWhereClause) {
            if protocolFunctionDeclaration.signature.effectSpecifiers?.throwsSpecifier == nil {
                throw SwiftyJSDiagnostic.functionsMustBeThrowable
            }

            let functionName = DeclReferenceExprSyntax(baseName: .identifier("callJS"))
            
            let arguments = LabeledExprListSyntax(itemsBuilder: {
                .init(label: "params", expression: ArrayExprSyntax(elements: ArrayElementListSyntax(itemsBuilder: {
                    for parameter in protocolFunctionDeclaration.signature.parameterClause.parameters {
                        ArrayElementListBuilder.Expression(expression: DeclReferenceExprSyntax(baseName: parameter.secondName ?? parameter.firstName))
                    }
                })))
            })

            let functionCall = FunctionCallExprSyntax(calledExpression: functionName,
                                                      leftParen: .leftParenToken(),
                                                      arguments: arguments,
                                                      rightParen: .rightParenToken())

            TryExprSyntax(expression: functionCall)
        }
    }
}
