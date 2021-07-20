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

struct WriteAccessInfo: Codable {
    let postboxId: String
    let publicKey: String
}

struct ConsentResponse {
    let authorizationCode: String
    let status: String
    let writeAccessInfo: WriteAccessInfo? // For write request authorization only
    
    init(code: String, status: String, writeAccessInfo: WriteAccessInfo? = nil) {
        self.authorizationCode = code
        self.status = status
        self.writeAccessInfo = writeAccessInfo
    }
}

class ConsentManager: NSObject {
    private let configuration: Configuration
    private var userConsentCompletion: ((Result<ConsentResponse, Error>) -> Void)?
    private var addServiceCompletion: ((Result<Void, Error>) -> Void)?
    private var safariViewController: SFSafariViewController?
    
    private enum ResponseKey: String {
        case state
        case code
        case postboxId
        case publicKey
        case success
        case errorCode
    }
    
    private enum Action: String {
        case auth
        case service
    }

    init(configuration: Configuration) {
        self.configuration = configuration
    }
    
    func requestUserConsent(preAuthCode: String, serviceId: Int?, completion: @escaping ((Result<ConsentResponse, Error>) -> Void)) {
        guard Thread.current.isMainThread else {
            DispatchQueue.main.async {
                self.requestUserConsent(preAuthCode: preAuthCode, serviceId: serviceId, completion: completion)
            }
            return
        }
        
        userConsentCompletion = completion
        CallbackService.shared().setCallbackHandler(self)
        var components = URLComponents(string: "\(APIConfig.baseURLPath)/apps/saas/authorize")!
        
        var percentEncodedQueryItems = [
            URLQueryItem(name: "code", value: preAuthCode),
            URLQueryItem(name: "callback", value: "\(self.configuration.redirectUri)\(Action.auth.rawValue)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)),
        ]
        
        if let serviceId = serviceId {
            percentEncodedQueryItems.append(URLQueryItem(name: "service", value: "\(serviceId)"))
        }
        
        components.percentEncodedQueryItems = percentEncodedQueryItems
        open(url: components.url!)
    }
    
    func addService(identifier: Int, token: String, completion: @escaping ((Result<Void, Error>) -> Void)) {
        var components = URLComponents(string: "\(APIConfig.baseURLPath)/apps/saas/onboard")!
        
        components.percentEncodedQueryItems = [
            URLQueryItem(name: "code", value: token),
            URLQueryItem(name: "callback", value: "\(self.configuration.redirectUri)\(Action.service.rawValue)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)),
            URLQueryItem(name: "service", value: "\(identifier)"),
        ]
        
        open(url: components.url!)
    }
    
    private func open(url: URL) {
        let viewController = SFSafariViewController(url: url)
        viewController.delegate = self
        viewController.presentationController?.delegate = self
        viewController.dismissButtonStyle = .cancel
        safariViewController = viewController
        
        UIViewController.topMostViewController()?.present(viewController, animated: true, completion: nil)
    }
    
    private func finishUserConsent(with result: Result<ConsentResponse, Error>) {
        guard Thread.current.isMainThread else {
            DispatchQueue.main.async {
                self.finishUserConsent(with: result)
            }
            return
        }
        
        reset()
        
        userConsentCompletion?(result)
        userConsentCompletion = nil
        addServiceCompletion = nil
    }
    
    private func finishAddService(with result: Result<Void, Error>) {
        guard Thread.current.isMainThread else {
            DispatchQueue.main.async {
                self.finishAddService(with: result)
            }
            return
        }
        
        reset()
        
        addServiceCompletion?(result)
        addServiceCompletion = nil
        userConsentCompletion = nil
    }
    
    private func userCancelled() {
        guard Thread.current.isMainThread else {
            DispatchQueue.main.async {
                self.userCancelled()
            }
            return
        }
        
        reset()
        
        addServiceCompletion?(.failure(ConsentError.userCancelled))
        addServiceCompletion = nil
        
        userConsentCompletion?(.failure(ConsentError.userCancelled))
        userConsentCompletion = nil
    }
    
    private func reset() {
        safariViewController?.delegate = nil
        safariViewController?.presentationController?.delegate = nil
        safariViewController = nil
    }
    
    private func handleAuthAction(parameters: [String: String?], presentingViewController: UIViewController) {
        let result: Result<ConsentResponse, Error>!
        defer {
            presentingViewController.dismiss(animated: true) {
                self.finishUserConsent(with: result)
            }
        }
        
        guard let success = parameters[ResponseKey.success.rawValue] else {
            result = .failure(CallbackError.invalidCallbackParameters)
            return
        }
        
        switch success {
        case "true":
            result = processAuthSuccessCallback(parameters: parameters)
            
        case "false":
            let error = processErrorCallback(parameters: parameters)
            result = .failure(error)
            
        default:
            result = .failure(CallbackError.invalidCallbackParameters)
        }
    }
    
    private func handleServiceAction(parameters: [String: String?], presentingViewController: UIViewController) {
        let result: Result<Void, Error>!
        defer {
            presentingViewController.dismiss(animated: true) {
                self.finishAddService(with: result)
            }
        }
        
        guard let success = parameters[ResponseKey.success.rawValue] else {
            result = .failure(CallbackError.invalidCallbackParameters)
            return
        }
        
        switch success {
        case "true":
            result = .success(())
            
        case "false":
            let error = processErrorCallback(parameters: parameters)
            result = .failure(error)
            
        default:
            result = .failure(CallbackError.invalidCallbackParameters)
        }
    }
    
    private func processAuthSuccessCallback(parameters: [String: String?]) -> Result<ConsentResponse, Error> {
        guard
            let status = parameters[ResponseKey.state.rawValue] as? String,
            let code = parameters[ResponseKey.code.rawValue] as? String else {
            return .failure(CallbackError.invalidCallbackParameters)
        }
        
        var writeAccessInfo: WriteAccessInfo?
        if
            let postboxId = parameters[ResponseKey.postboxId.rawValue] as? String,
            let publicKey = parameters[ResponseKey.publicKey.rawValue] as? String {
            writeAccessInfo = .init(postboxId: postboxId, publicKey: publicKey)
        }

        let response = ConsentResponse(code: code, status: status, writeAccessInfo: writeAccessInfo)
        return .success(response)
    }
    
    private func processErrorCallback(parameters: [String: String?]) -> ConsentError {
        guard
            let errorCode = parameters[ResponseKey.errorCode.rawValue] as? String,
            let error = ConsentError(rawValue: errorCode) else {
            return .unexpectedError
        }
        
        return error
    }
}

extension ConsentManager: CallbackHandler {
    func canHandleAction(_ action: String) -> Bool {
        Action(rawValue: action) != nil
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
        
        guard let actionToHandle = Action(rawValue: action) else {
            return
        }
        
        switch actionToHandle {
        case .auth:
            handleAuthAction(parameters: parameters, presentingViewController: presentingViewController)
        
        case .service:
            handleServiceAction(parameters: parameters, presentingViewController: presentingViewController)
        }
    }
}

extension ConsentManager: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        guard controller === safariViewController else {
            return
        }
        
        userCancelled()
    }
}

extension ConsentManager: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        guard presentationController.presentedViewController === safariViewController else {
            return
        }
        
        userCancelled()
    }
}
