// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftData",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "SwiftData",
            targets: ["ios-realm-swift"]),
    ],
    dependencies: [
        .package(url: "https://github.com/realm/realm-swift.git", .upToNextMajor(from: "20.0.3"))
    ],
    targets: [
        .target(
            name: "ios-realm-swift",
            dependencies: [
                .product(name: "Realm", package: "realm-swift"),
                .product(name: "RealmSwift", package: "realm-swift")
            ]
        ),
        .testTarget(
            name: "ios-realm-swiftTests",
            dependencies: ["ios-realm-swift"]
        ),
    ]
)
