//
//  DynamicallyKeyedArray.swift
//  DigiMeSDK
//
//  Created on 24/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

struct DynamicallyKeyedArray<T: Decodable>: Decodable {

    typealias ArrayType = [T]

    private var array: ArrayType

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
        let container = try decoder.container(keyedBy: DynamicCodingKey.self)

        var tempArray = ArrayType()

        for key in container.allKeys {
            let decodedObject = try container.decode(T.self, forKey: DynamicCodingKey(stringValue: key.stringValue)!)
            tempArray.append(decodedObject)
        }

        array = tempArray
    }
}

extension DynamicallyKeyedArray: Collection {

    // Required nested types, that tell Swift what our collection contains
    typealias Index = ArrayType.Index
    typealias Element = ArrayType.Element

    // The upper and lower bounds of the collection, used in iterations
    var startIndex: Index {
        array.startIndex
    }
    
    var endIndex: Index {
        array.endIndex
    }

    // Required subscript, based on a dictionary index
    subscript(index: Index) -> Iterator.Element {
        array[index]
    }

    // Method that returns the next index when iterating
    func index(after i: Index) -> Index {
        array.index(after: i)
    }
}
