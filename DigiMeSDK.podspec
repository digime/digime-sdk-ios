Pod::Spec.new do |s|

  s.name         	= "DigiMeSDK"
  s.version      	= "2.4.0"
  s.summary      	= "digi.me iOS Consent Access SDK"
  s.homepage     	= "https://github.com/digime/digime-sdk-ios"
  s.license      	= { :type => "MIT", :file => "LICENSE" }
  s.author       	= { "digi.me Ltd." => "ios@digi.me" }
  s.platform     	= :ios, "10.0"
  s.source       	= { 
	:git => "https://github.com/digime/digime-sdk-ios.git",
	:branch => s.version,
	:tag => s.version
  } 

  s.default_subspec = 'Core'
  
  s.subspec 'Core' do |ss|
    ss.source_files  	= "DigiMeSDK/Core/Classes/**/*.{h,m}"
    ss.resources       = ["DigiMeSDK/Core/Assets/*.{der}"]
    ss.frameworks    	= "Foundation", "UIKit", "CoreGraphics", "Security", "StoreKit"
    ss.private_header_files = 'DigiMeSDK/Core/Classes/Network/*.h', 
    	'DigiMeSDK/Core/Classes/Security/*.h',
    	'DigiMeSDK/Core/Classes/Utility/*.h',
    	'DigiMeSDK/Core/Classes/DMEAuthorizationManager.h'
  end

end
