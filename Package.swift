// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DocumentScanner",
    platforms: [
        .iOS(.v16)
    ],
    targets: [
        .executableTarget(
            name: "DocumentScanner",
            path: ".",
            exclude: ["Package.swift"],
            resources: [
                .process("Info.plist")
            ]
        )
    ]
)
