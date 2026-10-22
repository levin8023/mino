// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Mino",
    platforms: [.macOS(.v13)],
    products: [.executable(name: "Mino", targets: ["Mino"])],
    targets: [
        .target(name: "MinoCore"),
        .executableTarget(name: "Mino", dependencies: ["MinoCore"]),
        // Command Line Tools do not include XCTest; keep the runner dependency-free.
        .executableTarget(name: "MinoCoreChecks", dependencies: ["MinoCore"], path: "Tests/MinoCoreTests")
    ]
)
