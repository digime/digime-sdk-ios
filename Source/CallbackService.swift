//
//  CallbackService.swift
//  DigiMeSDK
//
//  Created on 10/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

public class CallbackService {
    
    public class func shared() -> CallbackService {
        sharedService
    }
    
    private static var sharedService: CallbackService = {
        CallbackService()
    }()
    
    private weak var callbackHandler: CallbackHandler?

    @discardableResult
    public func handleCallback(url: URL) -> Bool {
        guard url.absoluteString.hasPrefix("digime-ca-") else {
            return false
        }
        
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            NSLog("Unable to parse callback url: \(url.absoluteString)")
            return false
        }
        
        guard let action = urlComponents.host else {
            NSLog("Unable to extract callback action")
            return false
        }
        
        guard
            let handler = callbackHandler,
            handler.canHandleAction(action) else {
            return false
        }
        
        let parameters = urlComponents.queryItems?.reduce(into: [String: String?]()) { result, item in
            result[item.name] = item.value
        } ?? [:]
        
        handler.handleAction(action, with: parameters)
        return true
    }
    
    func setCallbackHandler(_ handler: CallbackHandler) {
        callbackHandler = handler
    }
    
    func removeCallbackHandler(_ handler: CallbackHandler) {
        if handler === callbackHandler {
            callbackHandler = nil
        }
    }
}

protocol CallbackHandler: AnyObject {
    func canHandleAction(_ action: String) -> Bool
    func handleAction(_ action: String, with parameters: [String: String?])
}
