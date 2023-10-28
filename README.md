# SwiftyJS

### Interact with your JavaScript code like Swift

## Getting Started
To get started with SwiftyJS:

1. Create a protocol
2. Use `@SwiftyJS` macro
3. Set JavaScript code or file to generated class.
4. And done

```swift
@SwiftyJS
protocol DataCreator {
    func createUser() throws -> User
}

let js = DataCreatorJSBridge()
js.loadFrom(jsCode: """
    function createUser() {
        return {
            id: 10,
            name: "Yusuf",
            score:5.1,
        }
    }
""")

print(try js.createUser())

// Output: User(id: "10", name: "Yusuf", score: 5.1)
```
