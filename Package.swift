// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TogglMac",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "TogglMac", targets: ["TogglMac"])
    ],
    targets: [
        .executableTarget(
            name: "TogglMac",
            path: "TogglMac",
            linkerSettings: [
            ]
        ),
        .testTarget(
            name: "TogglMacTests",
            dependencies: ["TogglMac"],
            path: "TogglMacTests"
        )
    ]
)
