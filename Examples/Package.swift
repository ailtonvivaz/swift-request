// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Examples",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
        .macCatalyst(.v13)
    ],
    products: [
        .executable(
            name: "Examples",
            targets: ["Examples"]
        ),
    ],
    dependencies: [
        .package(name: "swift-request", path: "../"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.6.4"))
    ],
    targets: [
        .executableTarget(
            name: "Examples",
            dependencies: [
                .product(name: "SwiftRequest", package: "swift-request"),
                .product(name: "Alamofire", package: "alamofire")
            ],
            path: "Sources"
        )
    ]
)
