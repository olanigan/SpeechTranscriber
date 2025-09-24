// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SpeechTranscriber",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/soffes/HotKey.git", from: "0.1.0"),
        .package(url: "https://github.com/exPHAT/SwiftWhisper.git", branch: "master"),
    ],
    targets: [
        .executableTarget(
            name: "SpeechTranscriber",
            dependencies: ["HotKey", "SwiftWhisper"],
            resources: [
                .copy("Resources/whisper-tiny.bin")
            ]
        ),
        .testTarget(
            name: "SpeechTranscriberTests",
            dependencies: ["SpeechTranscriber"]
        ),
    ]
)
