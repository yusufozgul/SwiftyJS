import SwiftDiagnostics

/// `SwiftyJSDiagnostic` is an enumeration defining specific error messages related to the SwiftyJS system.
///
/// It conforms to the `DiagnosticMessage` and `Error` protocols to provide comprehensive error information
/// and integrate smoothly with error handling mechanisms.
///
/// - Note: The `SwiftyJSDiagnostic` enum can be expanded to include more diagnostic cases as
///         the SwiftyJS system grows and needs to handle more error types.
enum SwiftyJSDiagnostic: String, DiagnosticMessage, Error {
    case onlyApplicableToProtocol
    case functionsMustBeThrowable
    case variablesGetterMustBeThrowable

    var message: String {
        switch self {
        case .onlyApplicableToProtocol: "'@SwiftyJS' can only be applied to a 'protocol'"
        case .functionsMustBeThrowable: "Functions must be throwable"
        case .variablesGetterMustBeThrowable: "Variables Getter must be throwable"
        }
    }

    var diagnosticID: MessageID {
        MessageID(domain: "SwiftyJSMacro", id: rawValue)
    }
    
    var severity: DiagnosticSeverity {
        switch self {
        case .onlyApplicableToProtocol: .error
        case .functionsMustBeThrowable: .error
        case .variablesGetterMustBeThrowable: .error
        }
    }
}
