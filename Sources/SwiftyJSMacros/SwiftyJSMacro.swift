import SwiftSyntax
import SwiftSyntaxMacros

/// `SwiftyJSMacro` is an implementation of the `SwiftyJS` macro, which generates a js bridge class
/// for the protocol to which the macro is added.
///
/// Example:
/// ```swift
/// @SwiftyJS
/// protocol JSServiceProtocol {
///     func createUSer(name: String, age: Int) -> User
/// }
/// ```
/// This will generate a `JSServiceProtocolBridge` class that implements `JSServiceProtocol` and records method calls.
public enum SwiftyJSMacro: PeerMacro {
    private static let jsFactory = JSFactory()

    public static func expansion(of node: AttributeSyntax,
                                 providingPeersOf declaration: some DeclSyntaxProtocol,
                                 in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        let protocolDeclaration = try extractProtocolDeclaration(from: declaration)
        let spyClassDeclaration = try jsFactory.classDeclaration(for: protocolDeclaration)

        return [DeclSyntax(spyClassDeclaration)]
    }

    static func extractProtocolDeclaration(from declaration: DeclSyntaxProtocol) throws -> ProtocolDeclSyntax {
        guard let protocolDeclaration = declaration.as(ProtocolDeclSyntax.self) else {
            throw SwiftyJSDiagnostic.onlyApplicableToProtocol
        }

        return protocolDeclaration
    }
}
