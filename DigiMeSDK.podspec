Pod::Spec.new do |s|

    s.name         	= "DigiMeSDK"
    s.version      	= "3.2.0"
    s.summary      	= "digi.me iOS Consent Access SDK"
    s.homepage     	= "https://github.com/digime/digime-sdk-ios"
    s.license      	= { :type => "MIT", :file => "LICENSE" }
    s.author       	= { "digi.me Ltd." => "ios@digi.me" }
    s.platform     	= :ios, "11.0"
    s.dependency "Brotli"
    s.dependency "GZIP"
    s.dependency "SwiftJWT"
    s.swift_version = "4.2"
    s.source       	= {
        :git => "https://github.com/digime/digime-sdk-ios.git",
        :branch => "master",
        :tag => s.version
    }
    
    s.source_files            = "DigiMeSDK/Core/Classes/**/*.{h,m,swift}", "DigiMeSDK/Postbox/Classes/**/*.{h,m,swift}", "DigiMeSDK/GuestConsent/Classes/**/*.{h,m,swift}", "DigiMeSDK/DigiMeSDK.h"
    s.resources            = ["DigiMeSDK/Core/Assets/**/*.*"]
    s.frameworks              = "Foundation", "UIKit", "CoreGraphics", "Security", "StoreKit"
    s.private_header_files = 'DigiMeSDK/Core/Classes/Entities/DMESession+Private.h',
    'DigiMeSDK/Core/Classes/Network/DMEAPIClient.h',
    'DigiMeSDK/Core/Classes/Network/DMEOperation.h',
    'DigiMeSDK/Core/Classes/Network/DMERequestFactory.h',
    'DigiMeSDK/Core/Classes/Security/DMECrypto.h',
    'DigiMeSDK/Core/Classes/Security/DMEDataDecryptor.h',
    'DigiMeSDK/Core/Classes/Security/DMEOAuthService.h',
    'DigiMeSDK/Core/Classes/Utility/DMECompressor.h',
    'DigiMeSDK/Core/Classes/Utility/DMEDataRequestSerializer.h',
    'DigiMeSDK/Core/Classes/Utility/DMEFileListDeserializer.h',
    'DigiMeSDK/Core/Classes/Utility/DMESessionDeserializer.h',
    'DigiMeSDK/Core/Classes/Utility/DMEStatusLogger.h',
    'DigiMeSDK/Core/Classes/Utility/DMEValidator.h',
    'DigiMeSDK/Core/Classes/Utility/UIViewController+DMEExtension.h',
    'DigiMeSDK/Core/Classes/DMEAPIClient+Private.h',
    'DigiMeSDK/Core/Classes/DMEAppCommunicator+Private.h',
    'DigiMeSDK/Core/Classes/DMENativeConsentManager.h',
    'DigiMeSDK/Core/Classes/DMEClient+Private.h',
    'DigiMeSDK/Core/Classes/DMEDataUnpacker.h',
    'DigiMeSDK/Core/Classes/DMEDataDecryptor.h',
    'DigiMeSDK/Postbox/Classes/DMEPostboxConsentManager.h',
    'DigiMeSDK/Postbox/Classes/DMEAPIClient+Postbox.h',
    'DigiMeSDK/GuestConsent/Classes/DMEGuestConsentManager.h',
    'DigiMeSDK/GuestConsent/Classes/DMEPreConsentView.h',
    'DigiMeSDK/GuestConsent/Classes/DMEPreConsentViewController.h'
end
