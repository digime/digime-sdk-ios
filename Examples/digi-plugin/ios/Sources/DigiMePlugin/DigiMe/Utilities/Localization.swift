//
//  Localization.swift
//  DigiMeSDKExample
//
//  Created on 11/02/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import Foundation

public class Localization {
    static let module: Bundle = {
#if SWIFT_PACKAGE
        let bundleName = "DigiPlugin_DigiMePlugin"

        let overrides: [URL]
#if DEBUG
        if let override = ProcessInfo.processInfo.environment["PACKAGE_RESOURCE_BUNDLE_PATH"]
            ?? ProcessInfo.processInfo.environment["PACKAGE_RESOURCE_BUNDLE_URL"] {
            overrides = [URL(fileURLWithPath: override)]
        } else {
            overrides = []
        }
#else
        overrides = []
#endif

        let candidates = overrides + [
            // Bundle should be present here when the package is linked into an App.
            Bundle.main.resourceURL,

            // Bundle should be present here when the package is linked into a framework.
            Bundle(for: Localization.self).resourceURL,

            // For command-line tools.
            Bundle.main.bundleURL,
        ]

        for candidate in candidates {
            let bundlePath = candidate?.appendingPathComponent(bundleName + ".bundle")
            if let bundle = bundlePath.flatMap(Bundle.init(url:)) {
                return bundle
            }
        }
        fatalError("unable to find bundle named DigiPlugin_DigiMePlugin")
#else
        return Bundle(for: Localization.self)
#endif
    }()
}
