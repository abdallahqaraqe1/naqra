// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "Naqra",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "Naqra",
            path: "Sources/Naqra",
            swiftSettings: [.unsafeFlags(["-parse-as-library"])]
        )
    ]
)
