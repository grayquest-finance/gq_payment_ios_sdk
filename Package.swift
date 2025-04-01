// swift-tools-version:5.10


import PackageDescription


let packageVersion = "1.0.3"


let package = Package(
    name: "GQPaymentIOS",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "GQPaymentIOS",
            targets: [
                "GQPaymentSDK",
            ]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/razorpay/razorpay-pod.git",
            exact: "1.3.13"
        ),
        .package(
            url: "https://github.com/cashfree/core-ios-sdk.git",
            exact: "2.2.0"
        ),
        .package(
            url: "https://github.com/easebuzz/paywitheasebuzz-ios-lib.git",
            exact: "1.1.0"
        )
    ],
    targets: [
        .binaryTarget(
            name: "GQPaymentIOSSDK",
            path: "GQPaymentIOSSDK.xcframework"
        ),
        .target(
            name: "GQPaymentSDK",
            dependencies: [
                "GQPaymentIOSSDK",
                "razorpay-pod",
                "core-ios-sdk",
                "paywitheasebuzz-ios-lib"
            ]
        )
    ],
    swiftLanguageVersions: [.v5]
)
