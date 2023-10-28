#if canImport(SwiftCompilerPlugin)
import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct SwiftyJSCompilerPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        SwiftyJSMacro.self
    ]
}
#endif
