// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "SwiftyJS",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        .library(
            name: "SwiftyJS",
            targets: ["SwiftyJS"]
        ),
        .executable(
            name: "SwiftyJSClient",
            targets: ["SwiftyJSClient"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),
    ],
    targets: [
        .macro(
            name: "SwiftyJSMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),

        .target(name: "SwiftyJS", dependencies: ["SwiftyJSMacros"]),

        .executableTarget(name: "SwiftyJSClient",
                          dependencies: ["SwiftyJS"],
                          resources: [.copy("Resources/TestFiles")]),

        .testTarget(
            name: "SwiftyJSTests",
            dependencies: [
                "SwiftyJSMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ]
)
