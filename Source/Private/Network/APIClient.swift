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
    
    func makeRequest<T: Route>(_ route: T, completion: @escaping (Result<T.ResponseType, Error>) -> Void) {
        let request = route.toUrlRequest()
                
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(HTTPError.noResponse))
                return
            }
            
            self.logStatusMessage(from: httpResponse)
            
            guard (200..<300).contains(httpResponse.statusCode) else {
                var errorWrapper: ErrorWrapper?
                if let data = data {
                    errorWrapper = try? data.decoded()
                }
                
                if let errorResponse = errorWrapper?.error {
                    Logger.error("Request: \(request.url?.absoluteString ?? "") failed with status code: \(httpResponse.statusCode), error code: \(errorResponse.code), message: \(errorResponse.message)")
                }
                else if let data = data, let message = String(data: data, encoding: .utf8) {
                    Logger.error("Request: \(request.url?.absoluteString ?? "") failed with status code: \(httpResponse.statusCode) \(message)")
                }
                else {
                    Logger.error("Request: \(request.url?.absoluteString ?? "") failed with status code: \(httpResponse.statusCode)")
                }
                
                completion(.failure(HTTPError.unsuccesfulStatusCode(httpResponse.statusCode, response: errorWrapper?.error)))
                return
            }
            
            guard let data = data else {
                completion(.failure(HTTPError.noData))
                return
            }
            
            let httpHeaders = httpResponse.allHeaderFields
            
            do {
                let result = try route.parseResponse(data: data, headers: httpHeaders)
                completion(.success(result))
            }
            catch {
                completion(.failure(error))
            }
        }.resume()
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
