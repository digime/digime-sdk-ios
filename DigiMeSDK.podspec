Pod::Spec.new do |s|

  s.name         	= "DigiMeSDK"
  s.version      	= "2.5.1"
  s.summary      	= "digi.me iOS Consent Access SDK"
  s.homepage     	= "https://github.com/digime/digime-sdk-ios"
  s.license      	= { :type => "MIT", :file => "LICENSE" }
  s.author       	= { "digi.me Ltd." => "ios@digi.me" }
  s.platform     	= :ios, "10.0"
  s.dependency "Brotli"
  s.dependency "GZIP"
  s.swift_version = "4.2"
  s.source       	= { 
    :git => "https://github.com/digime/digime-sdk-ios.git",
    :branch => s.version,
    :tag => s.version
    } 
    
    s.default_subspec = 'Core'
    
    s.subspec 'Core' do |ss|
      ss.source_files  	      = "DigiMeSDK/Core/Classes/**/*.{h,m,swift}", "DigiMeSDK/Postbox/Classes/**/*.{h,m,swift}", "DigiMeSDK/GuestConsent/Classes/**/*.{h,m,swift}", "DigiMeSDK/DigiMeSDK.h"
      ss.resources            = ["DigiMeSDK/Core/Assets/*.{der}"]
      ss.frameworks    	      = "Foundation", "UIKit", "CoreGraphics", "Security", "StoreKit"
      ss.private_header_files = 'DigiMeSDK/Core/Classes/Entities/DMESession+Private.h',
	'DigiMeSDK/Core/Classes/Network/DMEAPIClient.h',
	'DigiMeSDK/Core/Classes/Network/DMEOperation.h',
	'DigiMeSDK/Core/Classes/Network/DMERequestFactory.h', 
	'DigiMeSDK/Core/Classes/Security/DMECertificatePinner.h',
	'DigiMeSDK/Core/Classes/Security/DMECrypto.h',
	'DigiMeSDK/Core/Classes/Security/DMEDataDecryptor.h',
	'DigiMeSDK/Core/Classes/Utility/*.h',
	'DigiMeSDK/Core/Classes/DMESessionManager.h',
	'DigiMeSDK/Core/Classes/DMEAPIClient+Private.h',
	'DigiMeSDK/Core/Classes/DMEAppCommunicator+Private.h',
	'DigiMeSDK/Core/Classes/DMENativeConsentManager.h',
	'DigiMeSDK/Core/Classes/DMEClient+Private.h',
	'DigiMeSDK/Core/Classes/DMEDataUnpacker.h',
	'DigiMeSDK/Core/Classes/DMEDataDecryptor.h',
	'DigiMeSDK/Postbox/Classes/DMEPostboxManager.h', 
	'DigiMeSDK/Postbox/Classes/DMEAPIClient+Postbox.h',
	'DigiMeSDK/GuestConsent/Classes/DMEGuestConsentManager.h', 
	'DigiMeSDK/GuestConsent/Classes/DMEPreConsentView.h',
	'DigiMeSDK/GuestConsent/Classes/DMEPreConsentViewController.h'
    end

    s.subspec 'Postbox' do |ss|
      ss.source_files  	      = "DigiMeSDK/Postbox/Classes/**/*.{h,m,swift}"
      ss.frameworks    	      = "Foundation", "UIKit"
      ss.xcconfig             = { 'OTHER_CFLAGS' => '$(inherited) -DDigiMeSDKPostbox' }
      ss.private_header_files = 'DigiMeSDK/Postbox/Classes/DMEPostboxManager.h', 
	'DigiMeSDK/Postbox/Classes/DMEAPIClient+Postbox.h'
      ss.dependency "DigiMeSDK/Core"
    end

    s.subspec 'GuestConsent' do |ss|
      ss.source_files         = "DigiMeSDK/GuestConsent/Classes/**/*.{h,m,swift}"
      ss.resources            = ["DigiMeSDK/Core/Assets/*.xcassets"]
      ss.frameworks           = "Foundation", "UIKit"
      ss.xcconfig 	      = { 'OTHER_CFLAGS' => '$(inherited) -DDigiMeSDKGuestConsent' }
      ss.private_header_files = 'DigiMeSDK/GuestConsent/Classes/DMEGuestConsentManager.h', 
	'DigiMeSDK/GuestConsent/Classes/DMEPreConsentView.h',
	'DigiMeSDK/GuestConsent/Classes/DMEPreConsentViewController.h'
      ss.dependency "DigiMeSDK/Core"
    end
end
