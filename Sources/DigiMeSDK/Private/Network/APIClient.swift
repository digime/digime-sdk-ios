//
//  APIClient.swift
//  DigiMeSDK
//
//  Created on 07/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

class APIClient {
    typealias HTTPHeader = [AnyHashable: Any]
    
    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json",
        ]
        
        return URLSession(configuration: configuration)
    }()
	
	private var urlPath: String
    
	init(with baseUrl: String?) {
		guard let baseUrl = baseUrl else {
			// if url path is not provided then set from the defaults
            self.urlPath = APIConfig.baseUrlPathWithVersion
			return
		}
		
		self.urlPath = baseUrl + APIConfig.version
	}
	
	func makeRequest<T: Route>(_ route: T, completion: @escaping (Result<T.ResponseType, SDKError>) -> Void) {
		let request = route.toUrlRequest(with: urlPath)
		session.dataTask(with: request) { data, response, error in
			self.handleResponse(route, request: request, data: data, response: response, error: error, completion: completion)
		}.resume()
	}
	
	func makeRequestFileUpload<T: Route>(_ route: T, uploadData: Data, completion: @escaping (Result<T.ResponseType, SDKError>) -> Void) {
		let request = route.toUrlRequest(with: urlPath)
		session.uploadTask(with: request, from: uploadData) { data, response, error in
			self.handleResponse(route, request: request, data: data, response: response, error: error, completion: completion)
		}.resume()
	}
	
	private func handleResponse<T: Route>(_ route: T, request: URLRequest, data: Data?, response: URLResponse?, error: Error?, completion: @escaping (Result<T.ResponseType, SDKError>) -> Void) {
		if let error = error {
			Logger.error(error.localizedDescription)
			completion(.failure(.urlRequestFailed(error: error)))
			return
		}
		
		guard let httpResponse = response as? HTTPURLResponse else {
			Logger.error("Request: \(request.url?.absoluteString ?? "") received no response")
			completion(.failure(.errorMakingRequestNoResponse))
			return
		}
		
		self.logStatusMessage(from: httpResponse)
		
		guard (200..<300).contains(httpResponse.statusCode) else {
			let resultError = self.parseHttpError(statusCode: httpResponse.statusCode, data: data, urlString: request.url?.absoluteString)
			
			completion(.failure(resultError))
			return
		}
		
		guard let data = data else {
			Logger.error("Request: \(request.url?.absoluteString ?? "") received no data")
			completion(.failure(.errorMakingRequest))
			return
		}
		
		let httpHeaders = httpResponse.allHeaderFields
		
		do {
			let result = try route.parseResponse(data: data, headers: httpHeaders)
			completion(.success(result))
		}
		catch let error as SDKError {
			completion(.failure(error))
		}
		catch {
			completion(.failure(SDKError.invalidData))
		}
	}
	
    private func parseHttpError(statusCode: Int, data: Data?, urlString: String?) -> SDKError {
        let errorResponse = try? data?.decoded() as APIErrorResponse?
        var error: APIError?
        var logMessage = "Request: \(urlString ?? "") failed with status code: \(statusCode)"
        if let apiError = errorResponse?.error {
            logMessage += ", error code: \(apiError.code), message: \(apiError.message), reference: \(apiError.reference ?? "n/a")"
            error = apiError
        }
        else if let data = data, let message = String(data: data, encoding: .utf8) {
            logMessage += " \(message)"
        }
        
        Logger.error(logMessage)
        
        guard let errorResponse = errorResponse else {
            return .httpResponseError(statusCode: statusCode, apiError: error)
        }
        
        switch (statusCode, errorResponse.error.code) {
        case (403, "SDKVersionInvalid"):
            return .invalidSdkVersion
            
        case (400, "ScopeOutOfBounds"):
            return .scopeOutOfBounds
            
        case (400, "InvalidContractDataRequest"):
            return .incorrectContractType
            
        default:
            return .httpResponseError(statusCode: statusCode, apiError: errorResponse.error)
        }
    }
    
    private func logStatusMessage(from response: HTTPURLResponse) {
        let headers = response.allHeaderFields
        guard
            let status = headers["x-digi-sdk-status"],
            let message = headers["x-digi-sdk-status-message"] else {
            return
        }
        
        Logger.info("\n===========================================================\nSDK Status: \(status)\n\(message)\n===========================================================")
    }
}
