//
//  ReturnFunctionUnitTests.swift
//  
//
//  Created by Yusuf Özgül on 4.11.2023.
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

final class ReturnFunctionUnitTests: XCTestCase {
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

    func testMacroWithAsyncFunction() throws {
#if canImport(SwiftyJSMacros)
        assertMacroExpansion(
            #"""
            @SwiftyJS
            protocol DataPlugin {
                func createUser() async throws -> User
            }
            """#,
            expandedSource: withAsyncFunctionResult,
            macros: testMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
}

private let withFunctionResult = #"""
protocol DataPlugin {
    func createUser() throws -> User
}

class DataPluginJSBridge: DataPlugin {
    private (set) var jsContext = JSContext()!
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

     private func callJS<T: Decodable>(functionName: String = #function, params: [Encodable] = []) async throws -> T {
        jsContext.exception = nil
        var jsParams: [Any] = []
        for param in params {
            jsParams.append(try encoder.encode(param, in: jsContext))
        }

        guard let functionName = functionName.components(separatedBy: "(").first,
              let function = jsContext.objectForKeyedSubscript(functionName) else {
            throw error("Function Not Found")
        }

        guard let promise = function.call(withArguments: jsParams) else {
            throw error("Function call failed")
        }

        guard jsContext.exception == nil else {
            let message = jsContext.exception.toString() ?? ""
            jsContext.exception = nil
            throw error(message)
        }

        return try await withCheckedThrowingContinuation { continuation in
            let onFulfilled: @convention(block) (JSValue) -> Void = { [weak self] in
                guard let self else { return }
                do {
                    let result = try decoder.decode(T.self, from: $0)
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
            promise.invokeMethod("then", withArguments: [unsafeBitCast(onFulfilled, to: JSValue.self)])
        }
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

    private func callJS(functionName: String = #function, params: [Encodable] = []) async throws {
        jsContext.exception = nil
        var jsParams: [Any] = []
        for param in params {
            jsParams.append(try encoder.encode(param, in: jsContext))
        }

        guard let functionName = functionName.components(separatedBy: "(").first,
              let function = jsContext.objectForKeyedSubscript(functionName) else {
            throw error("Function Not Found")
        }

        let promise = function.call(withArguments: jsParams)

        guard jsContext.exception == nil else {
            let message = jsContext.exception.toString() ?? ""
            jsContext.exception = nil
            throw error(message)
        }

        await withCheckedContinuation { continuation  in
            let onFulfilled: @convention(block) (JSValue) -> Void = { _ in
                continuation.resume(returning: ())
            }
            promise?.invokeMethod("then", withArguments: [unsafeBitCast(onFulfilled, to: JSValue.self)])
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

private let withAsyncFunctionResult = #"""
protocol DataPlugin {
    func createUser() async throws -> User
}

class DataPluginJSBridge: DataPlugin {
    private (set) var jsContext = JSContext()!
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

     private func callJS<T: Decodable>(functionName: String = #function, params: [Encodable] = []) async throws -> T {
        jsContext.exception = nil
        var jsParams: [Any] = []
        for param in params {
            jsParams.append(try encoder.encode(param, in: jsContext))
        }

        guard let functionName = functionName.components(separatedBy: "(").first,
              let function = jsContext.objectForKeyedSubscript(functionName) else {
            throw error("Function Not Found")
        }

        guard let promise = function.call(withArguments: jsParams) else {
            throw error("Function call failed")
        }

        guard jsContext.exception == nil else {
            let message = jsContext.exception.toString() ?? ""
            jsContext.exception = nil
            throw error(message)
        }

        return try await withCheckedThrowingContinuation { continuation in
            let onFulfilled: @convention(block) (JSValue) -> Void = { [weak self] in
                guard let self else { return }
                do {
                    let result = try decoder.decode(T.self, from: $0)
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
            promise.invokeMethod("then", withArguments: [unsafeBitCast(onFulfilled, to: JSValue.self)])
        }
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

    private func callJS(functionName: String = #function, params: [Encodable] = []) async throws {
        jsContext.exception = nil
        var jsParams: [Any] = []
        for param in params {
            jsParams.append(try encoder.encode(param, in: jsContext))
        }

        guard let functionName = functionName.components(separatedBy: "(").first,
              let function = jsContext.objectForKeyedSubscript(functionName) else {
            throw error("Function Not Found")
        }

        let promise = function.call(withArguments: jsParams)

        guard jsContext.exception == nil else {
            let message = jsContext.exception.toString() ?? ""
            jsContext.exception = nil
            throw error(message)
        }

        await withCheckedContinuation { continuation  in
            let onFulfilled: @convention(block) (JSValue) -> Void = { _ in
                continuation.resume(returning: ())
            }
            promise?.invokeMethod("then", withArguments: [unsafeBitCast(onFulfilled, to: JSValue.self)])
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
    func createUser() async throws -> User {
        try await callJS(params: [])
    }
}
"""#
