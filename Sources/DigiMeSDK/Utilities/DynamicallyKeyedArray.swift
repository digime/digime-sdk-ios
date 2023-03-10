//
//  DynamicallyKeyedArray.swift
//  DigiMeSDK
//
//  Created on 24/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

public struct DynamicallyKeyedArray<T: Decodable>: Decodable {

    public typealias ArrayType = [T]

    private var array: ArrayType

	public struct DynamicCodingKey: CodingKey {

        // Use for string-keyed dictionary
        public var stringValue: String
        public init?(stringValue: String) {
            self.stringValue = stringValue
        }

        // Use for integer-keyed dictionary
        public var intValue: Int?
        public init?(intValue: Int) {
            // We are not using this, thus just return nil
            return nil
        }
    }

    public init(from decoder: Decoder) throws {
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
	public typealias Index = ArrayType.Index
	public typealias Element = ArrayType.Element

    // The upper and lower bounds of the collection, used in iterations
	public var startIndex: Index {
        array.startIndex
    }
    
	public var endIndex: Index {
        array.endIndex
    }

    // Required subscript, based on a dictionary index
	public subscript(index: Index) -> Iterator.Element {
        array[index]
    }

    // Method that returns the next index when iterating
	public func index(after i: Index) -> Index {
        array.index(after: i)
    }
}
