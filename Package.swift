// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "UndoController",
    platforms: [.iOS(.v14), .macOS(.v11)],
    products: [
        .library(
            name: "UndoController",
            targets: ["UndoController"]),
    ],
    targets: [
        .target(
            name: "UndoController",
            dependencies: []),
        .testTarget(
            name: "UndoControllerTests",
            dependencies: ["UndoController"]),
    ]
)
