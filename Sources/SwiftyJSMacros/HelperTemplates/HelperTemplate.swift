/// Bridge Class default functions and variables
/// Imports must be declare manually due to macro isn't allow import declarations
/// 
let helperTemplate = #"""
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
        jsContext.exceptionHandler = { (context, value) in
            guard let value = value?.toString() else { return }
            print(value)
            //            throw error(value)
        }

        var jsParams: [Any] = []
        for param in params {
            jsParams.append(try encoder.encode(param, in: jsContext))
        }

        guard let function = jsContext.objectForKeyedSubscript(functionName.replacingOccurrences(of: "()", with: "")) else {
            throw error("Function Not Found")
        }

        guard let result = function.call(withArguments: jsParams) else {
            throw error("Function call failed")
        }

        return try decoder.decode(T.self, from: result)
    }

    private func callJS(functionName: String = #function, params: [Encodable] = []) throws {
        jsContext.exceptionHandler = { (context, value) in
            guard let value = value?.toString() else { return }
            print(value)
            //            throw error(value)
        }

        var jsParams: [Any] = []
        for param in params {
            jsParams.append(try encoder.encode(param, in: jsContext))
        }

        guard let function = jsContext.objectForKeyedSubscript(functionName.replacingOccurrences(of: "()", with: "")) else {
            throw error("Function Not Found")
        }

        function.call(withArguments: jsParams)
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

"""#
