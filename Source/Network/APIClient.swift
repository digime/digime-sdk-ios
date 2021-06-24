//
//  APIClient.swift
//  DigiMeSDK
//
//  Created on 07/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

enum HTTPError: Error {
    case noResponse
    case noData
    case unsuccesfulStatusCode(Int, response: ErrorResponse?)
}

struct ErrorResponse: Decodable {
    struct Recovery: Decodable {
        let validAt: TimeInterval
    }
    
    let code: String
    let message: String
    let recovery: Recovery?
}

struct ErrorWrapper: Decodable {
    let error: ErrorResponse
}

class APIClient {
    
    private let credentialCache: CredentialCache
    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json",
        ]
        
        return URLSession(configuration: configuration)
    }()
    
    lazy var agent: Agent = {
        let version = Bundle(for: Self.self).object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        return Agent(name: "ios", version: version)
    }()
    
    init(credentialCache: CredentialCache) {
        self.credentialCache = credentialCache
    }

    func makeRequest<T: Decodable>(_ router: NetworkRouter, completion: @escaping (Result<T, Error>) -> Void) {
        guard let request = try? router.asURLRequest() else {
            return
        }
        
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
                    NSLog("Request: \(request.url?.absoluteString ?? "") failed with status code: \(httpResponse.statusCode), error code: \(errorResponse.code), message: \(errorResponse.message)")
                }
                else if let data = data, let message = String(data: data, encoding: .utf8) {
                    NSLog("Request: \(request.url?.absoluteString ?? "") failed with status code: \(httpResponse.statusCode) \(message)")
                }
                else {
                    NSLog("Request: \(request.url?.absoluteString ?? "") failed with status code: \(httpResponse.statusCode)")
                }
                
                completion(.failure(HTTPError.unsuccesfulStatusCode(httpResponse.statusCode, response: errorWrapper?.error)))
                return
            }
            
            guard let data = data else {
                completion(.failure(HTTPError.noData))
                return
            }
            
            do {
                let result = try data.decoded() as T
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
        
        NSLog("\n===========================================================\nSDK Status: \(status)\n\(message)\n===========================================================")
    }
}
