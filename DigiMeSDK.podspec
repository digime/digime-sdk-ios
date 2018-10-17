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
  #s.source_files  	= "DigiMeSDK/**/*.{h,m}"
  s.frameworks    	= "Foundation", "UIKit", "CoreGraphics", "Security", "StoreKit"
  s.resources       = ["DigiMeSDK/Assets/*.{der}"]
  
  s.default_subspec = 'Core'
  s.subspec 'Core' do |ss|
    ss.source_files  	= "DigiMeSDK/**/*.{h,m}"
  end

end
