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
            targets: ["GQPaymentIOSSDK"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/razorpay/razorpay-pod.git",
            from: "1.3.13"
        ),
        .package(
            url: "https://github.com/cashfree/core-ios-sdk.git",
            from: "2.2.0"
        ),
        .package(
            url: "https://github.com/easebuzz/paywitheasebuzz-ios-lib.git",
            from: "1.1.0"
        ),
        .packa
    ],
    targets: [
        .target(
            name: "GQPaymentIOSSDK",
            path: "GQPaymentIOSSDK/Classes/**/*"
        ),
        .binaryTarget(
            name: "GQPaymentIOSSDK",
            path: "GQPaymentIOSSDK.xcframework"
        )
    ],
    swiftLanguageVersions: [.v5]
)
