Pod::Spec.new do |s|

    s.name         	= "DigiMeSDK"
    s.version      	= "5.0.0"
    s.summary      	= "digi.me iOS Consent Access SDK"
    s.homepage     	= "https://github.com/digime/digime-sdk-ios"
    s.license      	= { :type => "MIT", :file => "LICENSE" }
    s.author       	= { "digi.me Ltd." => "ios@digi.me" }
    s.platform     	= :ios, "13.0"
    s.dependency "Brotli"
    s.dependency "GzipSwift"
    s.dependency "SwiftJWT"
    s.swift_version = "5.0"
    s.source       	= {
        :git => "https://github.com/digime/digime-sdk-ios.git",
        :branch => "master",
        :tag => s.version
    }
    
    s.source_files            = "Source/**/*.swift"
#     s.resources            = ["DigiMeSDK/Core/Assets/**/*.*"]
#     s.frameworks              = "Foundation", "UIKit", "CoreGraphics", "Security", "StoreKit"

end
