//
//  ConsentManager.swift
//  DigiMeSDK
//
//  Created on 11/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation
import SafariServices

final class ConsentManager: NSObject {
    private let configuration: Configuration
    private var userConsentCompletion: ((Result<ConsentResponse, SDKError>) -> Void)?
    private var addServiceCompletion: ((Result<Void, SDKError>) -> Void)?
    private var safariViewController: SFSafariViewController?
	private var localServiceRequested = false
	
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
    
    func requestUserConsent(preAuthCode: String, serviceId: Int?, completion: @escaping ((Result<ConsentResponse, SDKError>) -> Void)) {
        guard Thread.current.isMainThread else {
            DispatchQueue.main.async {
                self.requestUserConsent(preAuthCode: preAuthCode, serviceId: serviceId, completion: completion)
            }
            return
        }
        
        userConsentCompletion = completion
        CallbackService.shared().setCallbackHandler(self)
		let baseUrl = self.configuration.baseUrl ?? APIConfig.baseUrl
        var components = URLComponents(string: "\(baseUrl)/apps/saas/authorize")!
        
        var percentEncodedQueryItems = [
            URLQueryItem(name: "code", value: preAuthCode),
            URLQueryItem(name: "callback", value: "\(self.configuration.redirectUri)\(Action.auth.rawValue)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)),
        ]
        
        if let serviceId = serviceId {
			if !localServiceRequested {
				localServiceRequested = serviceId == DeviceOnlyServices.appleHealth.rawValue
			}
            percentEncodedQueryItems.append(URLQueryItem(name: "service", value: "\(serviceId)"))
        }
        
        components.percentEncodedQueryItems = percentEncodedQueryItems
        open(url: components.url!)
    }
    
    func addService(identifier: Int, token: String, completion: @escaping ((Result<Void, SDKError>) -> Void)) {
        guard Thread.current.isMainThread else {
            DispatchQueue.main.async {
                self.addService(identifier: identifier, token: token, completion: completion)
            }
            return
        }
        
        addServiceCompletion = completion
        CallbackService.shared().setCallbackHandler(self)
		let baseUrl = self.configuration.baseUrl ?? APIConfig.baseUrl
        var components = URLComponents(string: "\(baseUrl)/apps/saas/onboard")!
        
		if !localServiceRequested {
			localServiceRequested = identifier == DeviceOnlyServices.appleHealth.rawValue
		}
		
        components.percentEncodedQueryItems = [
            URLQueryItem(name: "code", value: token),
            URLQueryItem(name: "callback", value: "\(self.configuration.redirectUri)\(Action.service.rawValue)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)),
            URLQueryItem(name: "service", value: "\(identifier)"),
        ]
        
        open(url: components.url!)
    }
    
    private func open(url: URL) {
        DispatchQueue.main.async {
			guard !self.configuration.authUsingExternalBrowser else {
				UIApplication.shared.open(url)
				return
			}
			
            let viewController = SFSafariViewController(url: url)
            viewController.delegate = self
            viewController.presentationController?.delegate = self
            viewController.dismissButtonStyle = .cancel
            self.safariViewController = viewController
            
            UIViewController.topMostViewController()?.present(viewController, animated: true, completion: nil)
        }
    }
    
    private func finishUserConsent(with result: Result<ConsentResponse, Error>) {
        guard Thread.current.isMainThread else {
            DispatchQueue.main.async {
                self.finishUserConsent(with: result)
            }
            return
        }
        
		guard localServiceRequested else {
			reset()
			userConsentCompletion?(mapErrors(result: result))
			userConsentCompletion = nil
			addServiceCompletion = nil
			localServiceRequested = false
			return
		}
		
		LocalDataCache().deviceDataRequested = true
		HealthKitService().requestAuthorization(typesToRead: [], typesToWrite: []) { _, _ in
			self.reset()
			self.userConsentCompletion?(self.mapErrors(result: result))
			self.userConsentCompletion = nil
			self.addServiceCompletion = nil
			self.localServiceRequested = false
		}
    }
    
    private func finishAddService(with result: Result<Void, Error>) {
        guard Thread.current.isMainThread else {
            DispatchQueue.main.async {
                self.finishAddService(with: result)
            }
            return
        }
        
		guard localServiceRequested else {
			reset()
			addServiceCompletion?(mapErrors(result: result))
			addServiceCompletion = nil
			userConsentCompletion = nil
			localServiceRequested = false
			return
		}
		
		LocalDataCache().deviceDataRequested = true
		HealthKitService().requestAuthorization(typesToRead: [], typesToWrite: []) { _, _ in
			self.reset()
			self.addServiceCompletion?(self.mapErrors(result: result))
			self.addServiceCompletion = nil
			self.userConsentCompletion = nil
			self.localServiceRequested = false
		}
    }
    
    private func mapErrors<T>(result: Result<T, Error>) -> Result<T, SDKError> {
        return result.mapError { error in
            switch error {
            case ConsentError.userCancelled:
                return .authorizationCancelled
            case ConsentError.serviceOnboardError:
                return .addingServiceFailed
            case ConsentError.unexpectedError:
                return .unexpectedErrorWhenParsingConsentResponse
            case let err as ConsentError:
                return .authorizationFailed(code: err.rawValue)
            default:
                return .other
            }
        }
    }
    
    private func userCancelled() {
        guard Thread.current.isMainThread else {
            DispatchQueue.main.async {
                self.userCancelled()
            }
            return
        }
        
        reset()
        
        addServiceCompletion?(.failure(.authorizationCancelled))
        addServiceCompletion = nil
        
        userConsentCompletion?(.failure(.authorizationCancelled))
        userConsentCompletion = nil
    }
    
    private func reset() {
		DispatchQueue.main.async {
			self.safariViewController?.delegate = nil
			self.safariViewController?.presentationController?.delegate = nil
			self.safariViewController = nil
		}
    }
    
    private func handleAuthAction(parameters: [String: String?], presentingViewController: UIViewController?) {
        let result: Result<ConsentResponse, Error>!
        defer {
			if let vc = presentingViewController {
				vc.dismiss(animated: true) {
					self.finishUserConsent(with: result)
				}
			}
			
			self.finishUserConsent(with: result)
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
    
    private func handleServiceAction(parameters: [String: String?], presentingViewController: UIViewController?) {
        let result: Result<Void, Error>!
        defer {
			if let vc = presentingViewController {
				vc.dismiss(animated: true) {
					self.finishAddService(with: result)
				}
			}
			
			self.finishAddService(with: result)
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

		if localServiceRequested {
			LocalDataCache().deviceDataRequested = true
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
        
		guard !configuration.authUsingExternalBrowser else {
			guard let actionToHandle = Action(rawValue: action) else {
				return
			}
			
			switch actionToHandle {
			case .auth:
				handleAuthAction(parameters: parameters, presentingViewController: nil)
			
			case .service:
				handleServiceAction(parameters: parameters, presentingViewController: nil)
			}
			
			return
		}
		
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
