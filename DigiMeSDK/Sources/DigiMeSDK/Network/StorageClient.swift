//
//  StorageClient.swift
//  DigiMeSDK
//
//  Created on 10/05/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import DigiMeCore
import Foundation

class StorageClient {
    typealias HTTPHeader = [AnyHashable: Any]

    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json",
        ]

        configuration.timeoutIntervalForRequest = 90.0
        return URLSession(configuration: configuration)
    }()

    private var urlPath: String

    init(with baseUrl: String?) {
        guard let baseUrl = baseUrl else {
            // if url path is not provided then set from the defaults
            self.urlPath = StorageClientConfig.baseUrlPathWithVersion
            return
        }

        self.urlPath = baseUrl + StorageClientConfig.version
    }

    @discardableResult
    func makeRequest<T: Route>(_ route: T, completion: @escaping (Result<T.ResponseType, SDKError>) -> Void) -> URLSessionDataTask?  {
        let request = route.toUrlRequest(with: urlPath)
        let task = session.dataTask(with: request) { data, response, error in
            self.handleResponse(route, request: request, data: data, response: response, error: error, completion: completion)
        }
        task.resume()
        return task
    }

    @discardableResult
    func makeRequestFileDownload<T: Route>(_ route: T, completion: @escaping (Result<T.ResponseType, SDKError>) -> Void) -> URLSessionDownloadTask?  {
        let request = route.toUrlRequest(with: urlPath)
        let task = session.downloadTask(with: request) { url, response, error in
            self.handleDownloadResponse(route, request: request, url: url, response: response, error: error, completion: completion)
        }
        task.resume()
        return task
    }

    @discardableResult
    func makeRequestFileUpload<T: Route>(_ route: T, uploadData: Data, completion: @escaping (Result<T.ResponseType, SDKError>) -> Void) -> URLSessionUploadTask? {
        let request = route.toUrlRequest(with: urlPath)
        let task = session.uploadTask(with: request, from: uploadData) { data, response, error in
            self.handleResponse(route, request: request, data: data, response: response, error: error, completion: completion)
        }
        task.resume()
        return task
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

#if targetEnvironment(simulator)
        DispatchQueue.global(qos: .background).async {
            FilePersistentStorage(with: .documentDirectory).store(data: data, fileName: "\(T.path.replacingOccurrences(of: "/", with: "-")).json")
        }
#endif
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

    private func handleDownloadResponse<T: Route>(_ route: T, request: URLRequest, url: URL?, response: URLResponse?, error: Error?, completion: @escaping (Result<T.ResponseType, SDKError>) -> Void) {
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
            let resultError = self.parseHttpError(statusCode: httpResponse.statusCode, data: nil, urlString: request.url?.absoluteString)
            completion(.failure(resultError))
            return
        }

        guard let url = url else {
            Logger.error("Request: \(request.url?.absoluteString ?? "") received no file url")
            completion(.failure(.errorMakingRequest))
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let httpHeaders = httpResponse.allHeaderFields
            
#if targetEnvironment(simulator)
            DispatchQueue.global(qos: .background).async {
                FilePersistentStorage(with: .documentDirectory).store(data: data, fileName: "\(T.path.replacingOccurrences(of: "/", with: "-")).json")
            }
#endif
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
        var logMessage = "Request: \(urlString ?? "") failed with status code: \(statusCode)"
        if let data = data, let message = String(data: data, encoding: .utf8) {
            logMessage += ", message: \(message)"
        }

        Logger.error(logMessage)

        return .storageResponseError(statusCode: statusCode, errorMessage: logMessage)
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
