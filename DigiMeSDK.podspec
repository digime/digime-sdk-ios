Pod::Spec.new do |s|

  s.name         	= "DigiMeSDK"
  s.version      	= "2.0.0"
  s.summary      	= "digi.me iOS Consent Access SDK"
  s.homepage     	= "http://www.digi.me"
  s.license      	= { :type => "MIT", :file => "LICENSE" }
  s.author       	= { "digi.me Ltd." => "ios@digi.me" }
  s.platform     	= :ios, "8.0"
  s.source       	= { :git => "https://github.com/digime/digime-sdk-ios.git", :branch => "#{s.version}", :tag => "#{s.version}" } 
  s.frameworks    	= "Foundation", "UIKit", "CoreGraphics", "Security"
  s.resources       = ["DigiMeSDK/Assets/*.{der}"]

  s.subspec 'Callbacks' do |cb|
    cb.source_files = 'Callbacks/*.{h}'
  end

  s.subspec 'Core' do |ss|
    ss.source_files = 'DigiMeSDK/Core/*.{h,m}'
  end

  s.subspec 'Entities' do |ss|
    ss.source_files = 'DigiMeSDK/Entities/*.{h,m}'
  end

  s.subspec 'Errors' do |ss|
    ss.source_files = 'DigiMeSDK/Errors/*.{h,m}'
  end

  s.subspec 'Network' do |ss|
    ss.source_files = 'DigiMeSDK/Network/*.{h,m}'
  end

  s.subspec 'Security' do |ss|
    ss.source_files = 'DigiMeSDK/Security/*.{h,m}'
  end

  s.subspec 'Utility' do |ss|
    ss.source_files = 'DigiMeSDK/Utility/*.{h,m}'
  end

end
