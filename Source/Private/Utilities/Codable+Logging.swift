//
//  Codable+Logging.swift
//  DigiMeSDK
//
//  Created on 08/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

extension Encodable {
    func encoded() throws -> Data {
        do {
            return try JSONEncoder().encode(self)
        }
        catch {
            if let error = (error as? EncodingError) {
                switch error {
                case .invalidValue(_, let context):
                    Logger.error("Error encoding `\(context.codingPath.compactMap { $0.stringValue }.joined(separator: "."))` in \(String(describing: self)): \(context.debugDescription)")
                default:
                    Logger.error("Error encoding \(String(describing: self)): \(error.localizedDescription)")
                }
            }
            else {
                Logger.error("Error encoding \(String(describing: self)): \(error.localizedDescription)")
            }
            
            throw error
        }
    }
    
    var dictionary: Any? {
        guard let data = try? encoded() else {
            return nil
        }
        
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments))
    }
}

extension Data {
    func decoded<T: Decodable>(dateDecodingStrategy: JSONDecoder.DateDecodingStrategy? = nil) throws -> T {
        do {
            let decoder = JSONDecoder()
            if let dateDecodingStrategy = dateDecodingStrategy {
                decoder.dateDecodingStrategy = dateDecodingStrategy
            }
            
            return try decoder.decode(T.self, from: self)
        }
        catch {
            if let error = (error as? DecodingError) {
                switch error {
                case .keyNotFound(_, let context):
                    Logger.error("Error decoding `\(context.codingPath.compactMap { $0.stringValue }.joined(separator: "."))` in \(String(describing: T.self)): \(context.debugDescription)")
                case .typeMismatch(_, let context):
                    Logger.error("Error decoding `\(context.codingPath.compactMap { $0.stringValue }.joined(separator: "."))` in \(String(describing: T.self)): \(context.debugDescription)")
                case .valueNotFound(_, let context):
                    Logger.error("Error decoding `\(context.codingPath.compactMap { $0.stringValue }.joined(separator: "."))` in \(String(describing: T.self)): \(context.debugDescription)")
                case .dataCorrupted(let context):
                    Logger.error("Error decoding `\(context.codingPath.compactMap { $0.stringValue }.joined(separator: "."))` in \(String(describing: T.self)): \(context.debugDescription)")
                default:
                    Logger.error("Error decoding \(String(describing: T.self)): \(error.localizedDescription)")
                }
            }
            else {
                Logger.error("Error decoding \(String(describing: T.self)): \(error.localizedDescription)")
            }
            
            throw error
        }
    }
}

extension Dictionary {
    func decoded<T: Decodable>() throws -> T {
        let data = try JSONSerialization.data(withJSONObject: self, options: [])
        return try data.decoded()
    }
}

extension Array {
    func decoded<T: Decodable>() throws -> T {
        let data = try JSONSerialization.data(withJSONObject: self, options: [])
        return try data.decoded()
    }
}
