// swift-tools-version:4.0


import PackageDescription


let package = Package(
    name: "ParserAutograph",
    products: [
        Product.executable(
            name: "ParserAutograph",
            targets: ["ParserAutograph"]
        ),
    ],
    dependencies: [
        Package.Dependency.package(
            url: "https://github.com/RedMadRobot/autograph",
            from: "1.0.0"
        )
    ],
    targets: [
        Target.target(
            name: "ParserAutograph",
            dependencies: ["Autograph"]
        ),
        Target.testTarget(
            name: "ParserAutographTests",
            dependencies: ["ParserAutograph"]
        ),
    ]
)
