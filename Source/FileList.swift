//
//  FileList.swift
//  DigiMeSDK
//
//  Created on 24/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

public struct FileListItem: Decodable, Equatable {
    let name: String
    let objectVersion: String
    let updatedDate: Date
}

public struct FileList: Decodable {
    let files: [FileListItem]
    let status: SyncStatus
    
    enum CodingKeys: String, CodingKey {
        case files = "fileList"
        case status
    }
}

struct SyncStatus: Decodable {
    let details: [SyncAccount]
    let state: SyncState
    
    enum CodingKeys: String, CodingKey {
        case details, state
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rawState = try container.decode(String.self, forKey: .state)
        state = SyncState(rawValue: rawState) ?? .unknown
        
        let detailsArray = try container.decode(DynamicallyKeyedArray<SyncAccount>.self, forKey: .details)
        details = detailsArray.flatMap { $0 }
    }
}

struct SyncAccount: Decodable {
    let identifier: String
    let state: SyncState
    let error: SyncError? // Only when partial or completed state
    
    enum CodingKeys: String, CodingKey {
        case state, error
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode name
        let rawState = try container.decode(String.self, forKey: .state)
        state = SyncState(rawValue: rawState) ?? .unknown
        
        error = try container.decodeIfPresent(SyncError.self, forKey: .error)
        
        // Extract identifier from coding path
        identifier = container.codingPath.first!.stringValue
    }
}

struct SyncError: Decodable {
    let code: String
    let statusCode: Int
    let message: String
}

enum SyncState: String, Decodable {
    case running
    case pending
    case partial
    case completed
    
    case unknown
}

extension FileList: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return false
    }
}


// Add generic parameter clause
struct DynamicallyKeyedArray<T: Decodable>: Decodable {

    typealias ArrayType = [T]

    private var array: ArrayType

    // Define DynamicCodingKey type needed for creating decoding container from JSONDecoder
    private struct DynamicCodingKey: CodingKey {

        // Use for string-keyed dictionary
        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }

        // Use for integer-keyed dictionary
        var intValue: Int?
        init?(intValue: Int) {
            // We are not using this, thus just return nil
            return nil
        }
    }

    init(from decoder: Decoder) throws {

        // Create decoding container using DynamicCodingKeys
        // The container will contain all the JSON first level key
        let container = try decoder.container(keyedBy: DynamicCodingKey.self)

        var tempArray = ArrayType()

        // Loop through each keys in container
        for key in container.allKeys {

            // ***
            // Decode T using key & keep decoded T object in tempArray
            let decodedObject = try container.decode(T.self, forKey: DynamicCodingKey(stringValue: key.stringValue)!)
            tempArray.append(decodedObject)
        }

        // Finish decoding all T objects. Thus assign tempArray to array.
        array = tempArray
    }
}

extension DynamicallyKeyedArray: Collection {

    // Required nested types, that tell Swift what our collection contains
    typealias Index = ArrayType.Index
    typealias Element = ArrayType.Element

    // The upper and lower bounds of the collection, used in iterations
    var startIndex: Index { return array.startIndex }
    var endIndex: Index { return array.endIndex }

    // Required subscript, based on a dictionary index
    subscript(index: Index) -> Iterator.Element {
        get { return array[index] }
    }

    // Method that returns the next index when iterating
    func index(after i: Index) -> Index {
        return array.index(after: i)
    }
}
