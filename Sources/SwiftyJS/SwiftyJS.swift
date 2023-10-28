// The Swift Programming Language
// https://docs.swift.org/swift-book


@attached(peer, names: suffixed(JSBridge))
public macro SwiftyJS() = #externalMacro(
    module: "SwiftyJSMacros",
    type: "SwiftyJSMacro"
)
