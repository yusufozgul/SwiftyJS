# SwiftyJS

### Interact with your JavaScript code like Swift

## Getting Started
To get started with SwiftyJS:

1. Create a protocol 🖋️
2. Use `@SwiftyJS` macro ❇️
3. Set JavaScript code or file to generated class. ⌨️
4. And done 🚀

```swift
@SwiftyJS
protocol DataCreator {
    var lastUser: User { get throws }
    
    func createUser() throws -> User
}

let js = DataCreatorJSBridge()
js.loadFrom(jsCode: """
    var lastUser = null;
    
    function createUser() {
        let user = {
            id: 10,
            name: "Yusuf",
            score:5.1,
        }

        lastUser = user;
        return user;  
    }
""")

print(try js.createUser())

// Output: User(id: "10", name: "Yusuf", score: 5.1)

try js.setLastUser(User(id: "7", name: "John", score: 1.3))
print(try js.lastUser)

// Output: User(id: "7", name: "John", score: 1.3)
```

## Dependencies

```swift
.package(url: "https://github.com/yusufozgul/SwiftyJS", from: "0.0.1")
.package(url: "https://github.com/theolampert/JSValueCoder", branch: "main")
```

## Features
- 🔥**Seamless Swift-JavaScript Interaction**: Integrate SwiftyJS into your Swift projects effortlessly. Define a Protocol with the @SwiftyJS macro and interact with JavaScript code seamlessly.
- 📁**Loading JavaScript Code**: Load JavaScript code files or string using the `{ProtocolName}JSBridge` class.
- 🤖**Call JavaScript Functions**: Using the Generated Class, call JavaScript functions and get results in a Swift-like manner.
- 🧾**Accessing JavaScript Data**: Seamlessly access JavaScript data from Swift using swift variable.
- 🔄**Updating JavaScript Data**: SwiftyJS also allows you to update JavaScript data from Swift. You can set the variable with setter function.
