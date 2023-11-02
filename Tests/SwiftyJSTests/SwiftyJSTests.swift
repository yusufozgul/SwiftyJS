import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(SwiftyJSMacros)
import SwiftyJSMacros

let testMacros: [String: Macro.Type] = [
    "SwiftyJS": SwiftyJSMacro.self,
]
#endif

final class SwiftyJSTests: XCTestCase {
    func testWithVariable() throws {
#if canImport(SwiftyJSMacros)
        assertMacroExpansion(
            """
            @SwiftyJS
            protocol DataPlugin {
                var test: String { get throws }
            }

            """,
            expandedSource: withVariableResult,
            macros: testMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }

    func testWithArrayVariable() throws {
#if canImport(SwiftyJSMacros)
        assertMacroExpansion(
            """
            @SwiftyJS
            protocol DataPlugin {
                var test: [String] { get throws }
            }

            """,
            expandedSource: withArrayVariableResult,
            macros: testMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }

    func testWithOptionalVariable() throws {
#if canImport(SwiftyJSMacros)
        assertMacroExpansion(
            """
            @SwiftyJS
            protocol DataPlugin {
                var test: String? { get throws }
            }

            """,
            expandedSource: withOptionalVariableResult,
            macros: testMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }

    func testWithOptionalArrayVariable() throws {
#if canImport(SwiftyJSMacros)
        assertMacroExpansion(
            """
            @SwiftyJS
            protocol DataPlugin {
                var test: [String?] { get throws }
            }

            """,
            expandedSource: withOptionalArrayVariableResult,
            macros: testMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }

    func testMacroWithFunction() throws {
#if canImport(SwiftyJSMacros)
        assertMacroExpansion(
            #"""
            @SwiftyJS
            protocol DataPlugin {
                func createUser() throws -> User
            }
            """#,
            expandedSource: withFunctionResult,
            macros: testMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
}

private let withVariableResult = #"""
protocol DataPlugin {
    var test: String { get throws }
}

class DataPluginJSBridge: DataPlugin {
    private var jsContext = JSContext()!
    private let encoder = JSValueEncoder()
    private let decoder = JSValueDecoder()

    func loadFrom(jsCode: String, resetContext: Bool = false) {
        if resetContext {
            jsContext = JSContext()
        }

        jsContext.evaluateScript(jsCode)
    }

    func loadFrom(url: URL, resetContext: Bool = false) throws {
        if resetContext {
            jsContext = JSContext()
        }

        let jsCode = try String(contentsOf: url)
        jsContext.evaluateScript(jsCode)
    }

    private func callJS<T: Decodable>(functionName: String = #function, params: [Encodable] = []) throws -> T {
        jsContext.exception = nil
        var jsParams: [Any] = []
        for param in params {
            jsParams.append(try encoder.encode(param, in: jsContext))
        }

        guard let functionName = functionName.components(separatedBy: "(").first,
              let function = jsContext.objectForKeyedSubscript(functionName) else {
            throw error("Function Not Found")
        }

        guard let result = function.call(withArguments: jsParams) else {
            throw error("Function call failed")
        }

        guard jsContext.exception == nil else {
            let message = jsContext.exception.toString() ?? ""
            jsContext.exception = nil
            throw error(message)
        }

        return try decoder.decode(T.self, from: result)
    }

    private func callJS(functionName: String = #function, params: [Encodable] = []) throws {
        jsContext.exception = nil
        var jsParams: [Any] = []
        for param in params {
            jsParams.append(try encoder.encode(param, in: jsContext))
        }

        guard let functionName = functionName.components(separatedBy: "(").first,
              let function = jsContext.objectForKeyedSubscript(functionName) else {
            throw error("Function Not Found")
        }

        function.call(withArguments: jsParams)

        guard jsContext.exception == nil else {
            let message = jsContext.exception.toString() ?? ""
            jsContext.exception = nil
            throw error(message)
        }
    }

    private func error(_ message: String, code: Int = 0, domain: String = "SwiftyJS", function: String = #function, file: String = #file, line: Int = #line) -> NSError {
        let functionKey = "\(domain).function"
        let fileKey = "\(domain).file"
        let lineKey = "\(domain).line"

        let error = NSError(domain: domain, code: code, userInfo: [
            NSLocalizedDescriptionKey: message,
            functionKey: function,
            fileKey: file,
            lineKey: line
        ])

        return error
    }
    var test: String {
        get throws {
          guard let result = jsContext.objectForKeyedSubscript("test") else {
              throw error("JSValue couldn't retrieve")
          }
          return try decoder.decode(String.self, from: result)
        }
    }
    func setTest(_ value: String) throws {
        let jsValue = try encoder.encode(value, in: jsContext)
        jsContext.setObject(jsValue, forKeyedSubscript: "test" as (NSCopying & NSObjectProtocol)?)
    }
}

"""#

private let withArrayVariableResult = #"""
protocol DataPlugin {
    var test: [String] { get throws }
}

class DataPluginJSBridge: DataPlugin {
    private var jsContext = JSContext()!
    private let encoder = JSValueEncoder()
    private let decoder = JSValueDecoder()

    func loadFrom(jsCode: String, resetContext: Bool = false) {
        if resetContext {
            jsContext = JSContext()
        }

        jsContext.evaluateScript(jsCode)
    }

    func loadFrom(url: URL, resetContext: Bool = false) throws {
        if resetContext {
            jsContext = JSContext()
        }

        let jsCode = try String(contentsOf: url)
        jsContext.evaluateScript(jsCode)
    }

    private func callJS<T: Decodable>(functionName: String = #function, params: [Encodable] = []) throws -> T {
        jsContext.exception = nil
        var jsParams: [Any] = []
        for param in params {
            jsParams.append(try encoder.encode(param, in: jsContext))
        }

        guard let functionName = functionName.components(separatedBy: "(").first,
              let function = jsContext.objectForKeyedSubscript(functionName) else {
            throw error("Function Not Found")
        }

        guard let result = function.call(withArguments: jsParams) else {
            throw error("Function call failed")
        }

        guard jsContext.exception == nil else {
            let message = jsContext.exception.toString() ?? ""
            jsContext.exception = nil
            throw error(message)
        }

        return try decoder.decode(T.self, from: result)
    }

    private func callJS(functionName: String = #function, params: [Encodable] = []) throws {
        jsContext.exception = nil
        var jsParams: [Any] = []
        for param in params {
            jsParams.append(try encoder.encode(param, in: jsContext))
        }

        guard let functionName = functionName.components(separatedBy: "(").first,
              let function = jsContext.objectForKeyedSubscript(functionName) else {
            throw error("Function Not Found")
        }

        function.call(withArguments: jsParams)

        guard jsContext.exception == nil else {
            let message = jsContext.exception.toString() ?? ""
            jsContext.exception = nil
            throw error(message)
        }
    }

    private func error(_ message: String, code: Int = 0, domain: String = "SwiftyJS", function: String = #function, file: String = #file, line: Int = #line) -> NSError {
        let functionKey = "\(domain).function"
        let fileKey = "\(domain).file"
        let lineKey = "\(domain).line"

        let error = NSError(domain: domain, code: code, userInfo: [
            NSLocalizedDescriptionKey: message,
            functionKey: function,
            fileKey: file,
            lineKey: line
        ])

        return error
    }
    var test: [String] {
        get throws {
          guard let result = jsContext.objectForKeyedSubscript("test") else {
              throw error("JSValue couldn't retrieve")
          }
          return try decoder.decode([String].self, from: result)
        }
    }
    func setTest(_ value: [String]) throws {
        let jsValue = try encoder.encode(value, in: jsContext)
        jsContext.setObject(jsValue, forKeyedSubscript: "test" as (NSCopying & NSObjectProtocol)?)
    }
}

"""#

private let withOptionalVariableResult = #"""
protocol DataPlugin {
    var test: String? { get throws }
}

class DataPluginJSBridge: DataPlugin {
    private var jsContext = JSContext()!
    private let encoder = JSValueEncoder()
    private let decoder = JSValueDecoder()

    func loadFrom(jsCode: String, resetContext: Bool = false) {
        if resetContext {
            jsContext = JSContext()
        }

        jsContext.evaluateScript(jsCode)
    }

    func loadFrom(url: URL, resetContext: Bool = false) throws {
        if resetContext {
            jsContext = JSContext()
        }

        let jsCode = try String(contentsOf: url)
        jsContext.evaluateScript(jsCode)
    }

    private func callJS<T: Decodable>(functionName: String = #function, params: [Encodable] = []) throws -> T {
        jsContext.exception = nil
        var jsParams: [Any] = []
        for param in params {
            jsParams.append(try encoder.encode(param, in: jsContext))
        }

        guard let functionName = functionName.components(separatedBy: "(").first,
              let function = jsContext.objectForKeyedSubscript(functionName) else {
            throw error("Function Not Found")
        }

        guard let result = function.call(withArguments: jsParams) else {
            throw error("Function call failed")
        }

        guard jsContext.exception == nil else {
            let message = jsContext.exception.toString() ?? ""
            jsContext.exception = nil
            throw error(message)
        }

        return try decoder.decode(T.self, from: result)
    }

    private func callJS(functionName: String = #function, params: [Encodable] = []) throws {
        jsContext.exception = nil
        var jsParams: [Any] = []
        for param in params {
            jsParams.append(try encoder.encode(param, in: jsContext))
        }

        guard let functionName = functionName.components(separatedBy: "(").first,
              let function = jsContext.objectForKeyedSubscript(functionName) else {
            throw error("Function Not Found")
        }

        function.call(withArguments: jsParams)

        guard jsContext.exception == nil else {
            let message = jsContext.exception.toString() ?? ""
            jsContext.exception = nil
            throw error(message)
        }
    }

    private func error(_ message: String, code: Int = 0, domain: String = "SwiftyJS", function: String = #function, file: String = #file, line: Int = #line) -> NSError {
        let functionKey = "\(domain).function"
        let fileKey = "\(domain).file"
        let lineKey = "\(domain).line"

        let error = NSError(domain: domain, code: code, userInfo: [
            NSLocalizedDescriptionKey: message,
            functionKey: function,
            fileKey: file,
            lineKey: line
        ])

        return error
    }
    var test: String? {
        get throws {
          guard let result = jsContext.objectForKeyedSubscript("test") else {
              throw error("JSValue couldn't retrieve")
          }
          return try decoder.decode(String?.self, from: result)
        }
    }
    func setTest(_ value: String?) throws {
        let jsValue = try encoder.encode(value, in: jsContext)
        jsContext.setObject(jsValue, forKeyedSubscript: "test" as (NSCopying & NSObjectProtocol)?)
    }
}

"""#

private let withOptionalArrayVariableResult = #"""
protocol DataPlugin {
    var test: [String?] { get throws }
}

class DataPluginJSBridge: DataPlugin {
    private var jsContext = JSContext()!
    private let encoder = JSValueEncoder()
    private let decoder = JSValueDecoder()

    func loadFrom(jsCode: String, resetContext: Bool = false) {
        if resetContext {
            jsContext = JSContext()
        }

        jsContext.evaluateScript(jsCode)
    }

    func loadFrom(url: URL, resetContext: Bool = false) throws {
        if resetContext {
            jsContext = JSContext()
        }

        let jsCode = try String(contentsOf: url)
        jsContext.evaluateScript(jsCode)
    }

    private func callJS<T: Decodable>(functionName: String = #function, params: [Encodable] = []) throws -> T {
        jsContext.exception = nil
        var jsParams: [Any] = []
        for param in params {
            jsParams.append(try encoder.encode(param, in: jsContext))
        }

        guard let functionName = functionName.components(separatedBy: "(").first,
              let function = jsContext.objectForKeyedSubscript(functionName) else {
            throw error("Function Not Found")
        }

        guard let result = function.call(withArguments: jsParams) else {
            throw error("Function call failed")
        }

        guard jsContext.exception == nil else {
            let message = jsContext.exception.toString() ?? ""
            jsContext.exception = nil
            throw error(message)
        }

        return try decoder.decode(T.self, from: result)
    }

    private func callJS(functionName: String = #function, params: [Encodable] = []) throws {
        jsContext.exception = nil
        var jsParams: [Any] = []
        for param in params {
            jsParams.append(try encoder.encode(param, in: jsContext))
        }

        guard let functionName = functionName.components(separatedBy: "(").first,
              let function = jsContext.objectForKeyedSubscript(functionName) else {
            throw error("Function Not Found")
        }

        function.call(withArguments: jsParams)

        guard jsContext.exception == nil else {
            let message = jsContext.exception.toString() ?? ""
            jsContext.exception = nil
            throw error(message)
        }
    }

    private func error(_ message: String, code: Int = 0, domain: String = "SwiftyJS", function: String = #function, file: String = #file, line: Int = #line) -> NSError {
        let functionKey = "\(domain).function"
        let fileKey = "\(domain).file"
        let lineKey = "\(domain).line"

        let error = NSError(domain: domain, code: code, userInfo: [
            NSLocalizedDescriptionKey: message,
            functionKey: function,
            fileKey: file,
            lineKey: line
        ])

        return error
    }
    var test: [String?] {
        get throws {
          guard let result = jsContext.objectForKeyedSubscript("test") else {
              throw error("JSValue couldn't retrieve")
          }
          return try decoder.decode([String?].self, from: result)
        }
    }
    func setTest(_ value: [String?]) throws {
        let jsValue = try encoder.encode(value, in: jsContext)
        jsContext.setObject(jsValue, forKeyedSubscript: "test" as (NSCopying & NSObjectProtocol)?)
    }
}

"""#


private let withFunctionResult = #"""
protocol DataPlugin {
    func createUser() throws -> User
}

class DataPluginJSBridge: DataPlugin {
    private var jsContext = JSContext()!
    private let encoder = JSValueEncoder()
    private let decoder = JSValueDecoder()

    func loadFrom(jsCode: String, resetContext: Bool = false) {
        if resetContext {
            jsContext = JSContext()
        }

        jsContext.evaluateScript(jsCode)
    }

    func loadFrom(url: URL, resetContext: Bool = false) throws {
        if resetContext {
            jsContext = JSContext()
        }

        let jsCode = try String(contentsOf: url)
        jsContext.evaluateScript(jsCode)
    }

    private func callJS<T: Decodable>(functionName: String = #function, params: [Encodable] = []) throws -> T {
        jsContext.exception = nil
        var jsParams: [Any] = []
        for param in params {
            jsParams.append(try encoder.encode(param, in: jsContext))
        }

        guard let functionName = functionName.components(separatedBy: "(").first,
              let function = jsContext.objectForKeyedSubscript(functionName) else {
            throw error("Function Not Found")
        }

        guard let result = function.call(withArguments: jsParams) else {
            throw error("Function call failed")
        }

        guard jsContext.exception == nil else {
            let message = jsContext.exception.toString() ?? ""
            jsContext.exception = nil
            throw error(message)
        }

        return try decoder.decode(T.self, from: result)
    }

    private func callJS(functionName: String = #function, params: [Encodable] = []) throws {
        jsContext.exception = nil
        var jsParams: [Any] = []
        for param in params {
            jsParams.append(try encoder.encode(param, in: jsContext))
        }

        guard let functionName = functionName.components(separatedBy: "(").first,
              let function = jsContext.objectForKeyedSubscript(functionName) else {
            throw error("Function Not Found")
        }

        function.call(withArguments: jsParams)

        guard jsContext.exception == nil else {
            let message = jsContext.exception.toString() ?? ""
            jsContext.exception = nil
            throw error(message)
        }
    }

    private func error(_ message: String, code: Int = 0, domain: String = "SwiftyJS", function: String = #function, file: String = #file, line: Int = #line) -> NSError {
        let functionKey = "\(domain).function"
        let fileKey = "\(domain).file"
        let lineKey = "\(domain).line"

        let error = NSError(domain: domain, code: code, userInfo: [
            NSLocalizedDescriptionKey: message,
            functionKey: function,
            fileKey: file,
            lineKey: line
        ])

        return error
    }
    func createUser() throws -> User {
        try callJS(params: [])
    }
}
"""#
