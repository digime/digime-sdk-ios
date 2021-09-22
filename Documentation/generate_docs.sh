#sourcekitten doc --objc SDKHeaders.h -- -x objective-c -isysroot $(xcrun --show-sdk-path) -I $(pwd) > objcDoc.json
sourcekitten doc --module-name DigiMeSDK -- -project ../Examples/DigiMeSDKExample/Pods/DigiMeSDK.xcodeproj > swiftDoc.json
jazzy
#remove generated docset as we don't need it
rm -rf ../docsets
#remove generated sourcekitten files
rm -rf swiftDoc.json
#rm -rf objcDoc.json
