// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ReadDeadRedemption",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "ReadDeadRedemption",
            targets: ["ReadDeadRedemption"]
        ),
    ],
    targets: [
        .target(
            name: "ReadDeadRedemption",
            path: "ReadDeadRedemption"
        ),
        .testTarget(
            name: "ReadDeadRedemptionTests",
            dependencies: ["ReadDeadRedemption"],
            path: "ReadDeadRedemptionTests"
        ),
    ]
)
