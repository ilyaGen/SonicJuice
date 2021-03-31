// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SonicJuice",
    platforms: [
        .macOS(.v10_14), .iOS(.v13)
        ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SonicJuice",
            targets: ["SonicJuice", "ObjCInterface"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "ObjCInterface",
            dependencies: [],
            publicHeadersPath: "include",
            cxxSettings: [
                .headerSearchPath("../CppHeaders"),
            ],
            linkerSettings: [
                .linkedFramework("AudioToolbox"),
                .linkedFramework("AVFoundation"),
                .linkedFramework("CoreAudio"),
                .linkedFramework("Foundation")
            ]
        ),
        .target(
            name: "SonicJuice",
            dependencies: ["ObjCInterface"]
            ),
        .testTarget(
            name: "SonicJuiceTests",
            dependencies: ["SonicJuice"],
            resources: [
                .copy("Resources")]
        ),
    ]
)
