import SwiftyJS
import JSValueCoder
import Foundation
import JavaScriptCore

struct User: Codable {
    let id: String
    let name: String
    let score: Double
}

@SwiftyJS
protocol DataCreator {
    var lastUser: User { get throws }

    func createUser() throws -> User
}

let js = DataCreatorJSBridge()
let jsFileURL = Bundle.module.url(forResource: "TestJSfile", withExtension: "js", subdirectory: "TestFiles")!
try js.loadFrom(url: jsFileURL)


print("Initial User: ")
print(try js.lastUser)

print("")

print("Create User: ")
print(try js.createUser())

print("")

print("Last User: ")
print(try js.lastUser)

print("")

print("Set Last User: ")
try js.setLastUser(User(id: "7", name: "John", score: 1.3))

print("")

print("Last User: ")
print(try js.lastUser)
