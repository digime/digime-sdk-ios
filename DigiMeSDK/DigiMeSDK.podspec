Pod::Spec.new do |s|

    s.name         	= "DigiMeSDK"
    s.version      	= "5.0.6"
    s.summary      	= "digi.me iOS Consent Access SDK"
    s.homepage     	= "https://github.com/digime/digime-sdk-ios"
    s.license      	= { :type => "MIT", :file => "LICENSE" }
    s.author       	= { "digi.me Ltd." => "ios@digi.me" }
    s.platform     	= :ios, "13.0"
    s.swift_version = "5.0"
    s.source       	= {
        :git => "https://github.com/digime/digime-sdk-ios.git",
        :branch => "master",
        :tag => s.version
    }
    
    s.source_files 	= "Sources/DigiMeSDK/**/*.swift"
    s.frameworks 	= "Foundation", "UIKit", "SafariServices", "CryptoKit", "Security", "HealthKit"
    s.dependency 'DigiMeCore', '~> 5.0.6'

end
