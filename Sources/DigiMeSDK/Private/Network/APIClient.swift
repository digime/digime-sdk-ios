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
    
    func makeRequest<T: Route>(_ route: T, completion: @escaping (Result<T.ResponseType, SDKError>) -> Void) {
        let request = route.toUrlRequest()

        session.dataTask(with: request) { data, response, error in
            if let error = error {
                Logger.error(error.localizedDescription)
                completion(.failure(.urlRequestFailed(error: error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                Logger.error("Request: \(request.url?.absoluteString ?? "") received no response")
                completion(.failure(.other))
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
                completion(.failure(.other))
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
        }.resume()
    }
    
    private func parseHttpError(statusCode: Int, data: Data?, urlString: String?) -> SDKError {
        let errorResponse = try? data?.decoded() as APIErrorResponse?
        
        var logMessage = "Request: \(urlString ?? "") failed with status code: \(statusCode)"
        if let apiError = errorResponse?.error {
            logMessage += ", error code: \(apiError.code), message: \(apiError.message)"
        }
        else if let data = data, let message = String(data: data, encoding: .utf8) {
            logMessage += " \(message)"
        }
        
        Logger.error(logMessage)
        
        guard let errorResponse = errorResponse else {
            return .httpResponseError(statusCode: statusCode, apiError: nil)
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
