//
//  ConsentManager.swift
//  DigiMeSDK
//
//  Created on 11/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation
import SafariServices

enum CallbackError: Error {
    case unexpectedCallbackAction
    case invalidCallbackParameters
}

struct AuthResponse {
    struct WriteInfo {
        let postboxId: String
        let publicKey: String
    }
    
    let authorizationCode: String
    let status: String
    let writeInfo: WriteInfo? // For write request authorization only
    
    init(code: String, status: String, writeInfo: WriteInfo? = nil) {
        self.authorizationCode = code
        self.status = status
        self.writeInfo = writeInfo
    }
}

class ConsentManager: NSObject {
    private let configuration: Configuration
    private var userConsentCompletion: ((Result<AuthResponse, Error>) -> Void)?
    private var safariViewController: SFSafariViewController?
    
    private enum ResponseKey: String {
        case state
        case code
        case postboxId
        case publicKey
    }

    init(configuration: Configuration) {
        self.configuration = configuration
    }
    
    func requestUserConsent(preAuthCode: String, serviceId: Int?, completion: @escaping ((Result<AuthResponse, Error>) -> Void)) {
        guard Thread.current.isMainThread else {
            DispatchQueue.main.async {
                self.requestUserConsent(preAuthCode: preAuthCode, serviceId: serviceId, completion: completion)
            }
            return
        }
        
        userConsentCompletion = completion
        CallbackService.shared().setCallbackHandler(self)
        var components = URLComponents(string: "https://api.development.devdigi.me/apps/saas/authorize")!
        
        var percentEncodedQueryItems = [
            URLQueryItem(name: "code", value: preAuthCode),
            URLQueryItem(name: "errorCallback", value: "\(self.configuration.redirectUri)error".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)),
            URLQueryItem(name: "successCallback", value: "\(self.configuration.redirectUri)auth".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)),
        ]
        
        if let serviceId = serviceId {
            percentEncodedQueryItems.append(URLQueryItem(name: "service", value: "\(serviceId)"))
        }
        
        components.percentEncodedQueryItems = percentEncodedQueryItems
        let url = components.url!
        let viewController = SFSafariViewController(url: url)
        viewController.delegate = self
        viewController.presentationController?.delegate = self
        viewController.dismissButtonStyle = .cancel
        safariViewController = viewController
        
        UIViewController.topMostViewController()?.present(viewController, animated: true, completion: nil)
    }
    
    private func finish(with result: Result<AuthResponse, Error>) {
        guard Thread.current.isMainThread else {
            DispatchQueue.main.async {
                self.finish(with: result)
            }
            return
        }
        
        safariViewController?.delegate = nil
        safariViewController?.presentationController?.delegate = nil
        safariViewController = nil
        
        userConsentCompletion?(result)
        userConsentCompletion = nil
    }
    
    private func processSuccessCallback(parameters: [String: String?]) -> Result<AuthResponse, Error> {
        guard
            let status = parameters[ResponseKey.state.rawValue] as? String,
            let code = parameters[ResponseKey.code.rawValue] as? String else {
            return .failure(CallbackError.invalidCallbackParameters)
        }
        
        var writeInfo: AuthResponse.WriteInfo?
        if
            let postboxId = parameters[ResponseKey.postboxId.rawValue] as? String,
            let publicKey = parameters[ResponseKey.publicKey.rawValue] as? String {
            writeInfo = .init(postboxId: postboxId, publicKey: publicKey)
        }

        let response = AuthResponse(code: code, status: status, writeInfo: writeInfo)
        return .success(response)
    }
    
    private func processErrorCallback(parameters: [String: String?]) -> AuthError {
        guard
            let code = parameters[ResponseKey.code.rawValue] as? String,
            let error = AuthError(rawValue: code) else {
            return .unexpectedError
        }
        
        return error
    }
}

extension ConsentManager: CallbackHandler {
    func canHandleAction(_ action: String) -> Bool {
        action == "auth" || action == "error"
    }
    
    func handleAction(_ action: String, with parameters: [String: String?]) {
        CallbackService.shared().removeCallbackHandler(self)
        
        // User could have opened in Safari Browser and cancelled/completed authentication in SafariViewController
        // then cancelled/completed authentication again in Browser,
        // in which case we ignore any callback from Browser as app has already handled a callback.
        guard
            let viewController = safariViewController,
            viewController.isViewLoaded,
            viewController.view.window != nil,
            let presentingViewController = viewController.presentingViewController else {
            return
        }
        
        let result: Result<AuthResponse, Error>!
        switch action {
        case "auth":
            result = processSuccessCallback(parameters: parameters)
            
        case "error":
            let error = processErrorCallback(parameters: parameters)
            result = .failure(error)
            
        default:
            result = .failure(CallbackError.unexpectedCallbackAction)
        }
        
        presentingViewController.dismiss(animated: true) {
            self.finish(with: result)
        }
    }
}

extension ConsentManager: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        guard controller === safariViewController else {
            return
        }
        
        finish(with: .failure(AuthError.userCancelled))
    }
    
    @available(iOS 14.0, *)
    func safariViewControllerWillOpenInBrowser(_ controller: SFSafariViewController) {
        guard controller === safariViewController else {
            return
        }
        
        
    }
}

extension ConsentManager: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        guard presentationController.presentedViewController === safariViewController else {
            return
        }
        
        finish(with: .failure(AuthError.userCancelled))
    }
}
