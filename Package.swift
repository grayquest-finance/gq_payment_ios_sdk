// swift-tools-version:5.10


import PackageDescription


let packageVersion = "1.0.3"


let package = Package(
    name: "GQPaymentIOSSDK",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "GQPaymentIOSSDK",
            targets: [
                "GQPaymentSDK",
                "GQPaymentIOSSDK"
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
        .target(
            name: "GQPaymentSDK",
            path: "GQPaymentIOSSDK/Classes/Sources"
        ),
        .binaryTarget(
            name: "GQPaymentIOSSDK",
            path: "Pod/GQPaymentIOSSDK.xcframework"
        )
    ],
    swiftLanguageVersions: [.v5]
)
