//
//  Route.swift
//  DigiMeSDK
//
//  Created on 15/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

protocol Route {
    associatedtype ResponseType
    static var method: String { get }
    static var path: String { get }
    
    var customHeaders: [String: String] { get }
    var queryParameters: [URLQueryItem] { get }
    var pathParameters: [String] { get }
    var requestBody: RequestBody? { get }
    
    func toUrlRequest(with baseUrl: String) -> URLRequest
    
    // Throws SDKError or DecodingError
    func parseResponse(data: Data, headers: [AnyHashable: Any]) throws -> ResponseType
}

extension Route {
    var customHeaders: [String: String] {
        [:]
    }
    
    var queryParameters: [URLQueryItem] {
        []
    }
    
    var pathParameters: [String] {
        []
    }
    
    var requestBody: RequestBody? {
        nil
    }
    
	func toUrlRequest(with baseUrl: String) -> URLRequest {
        // Add all the parameters
		var urlComponents = URLComponents(string: baseUrl)!
        
        if !queryParameters.isEmpty {
            urlComponents.queryItems = queryParameters
        }
        
        var url = urlComponents.url!.appendingPathComponent(Self.path)
        
        pathParameters.forEach {
            url.appendPathComponent($0)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = Self.method
        
        customHeaders.forEach { request.setValue($1, forHTTPHeaderField: $0) }

        if let body = requestBody {
            request.httpBody = body.data
            body.headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        }
        
        return request
    }
}

extension Route where ResponseType == Void {
    func parseResponse(data: Data, headers: [AnyHashable: Any]) throws -> ResponseType {
        return ()
    }
}

extension Route where ResponseType == Data {
    func parseResponse(data: Data, headers: [AnyHashable: Any]) throws -> ResponseType {
        return data
    }
}

extension Route where ResponseType: Decodable {
    func parseResponse(data: Data, headers: [AnyHashable: Any]) throws -> ResponseType {
        return try data.decoded() as ResponseType
    }
}

struct Empty: Codable {
}
