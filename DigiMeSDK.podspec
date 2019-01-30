Pod::Spec.new do |s|

  s.name         	= "DigiMeSDK"
  s.version      	= "2.4.1"
  s.summary      	= "digi.me iOS Consent Access SDK"
  s.homepage     	= "https://github.com/digime/digime-sdk-ios"
  s.license      	= { :type => "MIT", :file => "LICENSE" }
  s.author       	= { "digi.me Ltd." => "ios@digi.me" }
  s.platform     	= :ios, "10.0"
  s.dependency "Brotli"
  s.dependency "GZIP"

  s.source       	= { 
    :git => "https://github.com/digime/digime-sdk-ios.git",
    :branch => s.version,
    :tag => s.version
    } 
    
    s.default_subspec = 'Core'
    
    s.subspec 'Core' do |ss|
      ss.source_files  	= "DigiMeSDK/Core/Classes/**/*.{h,m}", "DigiMeSDK/DigiMeSDK.h"
      ss.resources       = ["DigiMeSDK/Core/Assets/*.{der}"]
      ss.frameworks    	= "Foundation", "UIKit", "CoreGraphics", "Security", "StoreKit"
      ss.private_header_files = 'DigiMeSDK/Core/Classes/Network/*.h', 
        'DigiMeSDK/Core/Classes/Utility/*.h',
        'DigiMeSDK/Core/Classes/Security/DME*.h',
        'DigiMeSDK/Core/Classes/DMEAuthorizationManager.h',
        'DigiMeSDK/Core/Classes/DMEClient+Private.h',
        'DigiMeSDK/Core/Classes/CASession+Private.h'
    end

    s.subspec 'Postbox' do |ss|
      ss.source_files  	= "DigiMeSDK/Postbox/Classes/**/*.{h,m}"
      ss.frameworks    	= "Foundation", "UIKit"
      ss.private_header_files = 'DigiMeSDK/Core/Classes/DMEPostboxManager.h'
      ss.xcconfig = { 'OTHER_CFLAGS' => '$(inherited) -DDigiMeSDKPostbox' }
      ss.dependency "DigiMeSDK/Core"
    end

    s.subspec 'Repository' do |ss|
      ss.source_files  	= "DigiMeSDK/Repository/Classes/**/*.swift"
      ss.frameworks    	= "Foundation"
      ss.dependency "DigiMeSDK/Core"
    end
end
