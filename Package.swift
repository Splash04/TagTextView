// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "TagTextView",
    platforms: [
        .iOS(.v15)
    ],
    
    products: [
        .library(name: "TagTextView", targets: ["TagTextView"])
    ],
    
    targets: [
        .target(name: "TagTextView", path: "Sources", resources: [.process("PrivacyInfo.xcprivacy")])
    ]
)
