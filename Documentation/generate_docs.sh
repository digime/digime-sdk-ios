# sourcekitten doc --objc SDKHeaders.h -- -x objective-c -isysroot $(xcrun --show-sdk-path) -I $(pwd) > objcDoc.json
# sourcekitten doc --module-name DigiMeSDK -- -project ../Examples/SkeletonSwift/Pods/DigiMeSDK.xcodeproj > swiftDoc.json
jazzy
