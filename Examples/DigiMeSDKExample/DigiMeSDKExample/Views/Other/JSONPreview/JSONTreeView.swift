//
//  JSONTreeView.swift
//  DigiMeSDKExample
//
//  Created on 17/02/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import SwiftUI

typealias JSON = [String: AnyHashable]

struct JSONTreeView: View {
	@State private var searchText = ""

    var depth: Int = 0

    private var keyValues: [(key: String, value: AnyHashable)]

    init(_ dictionary: JSON, depth: Int = 0) {
        self.keyValues = dictionary.sorted { $0.key < $1.key }.map { key, value in
            (key: key, value: value)
        }
        self.depth = depth
    }

    init(_ array: [JSON], prefix key: String = "", depth: Int = 0) {
        self.keyValues = array.enumerated().map { offset, element in
            (key: "\(key)[\(offset)]", value: element)
        }
        self.depth = depth
    }

    init(_ source: [(key: String, value: AnyHashable)], depth: Int = 0) {
        self.keyValues = source
        self.depth = depth
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: 0) {
                ForEach(Array(filtered.enumerated()), id: \.element.key) { index, _ in
                    VStack(alignment: .leading, spacing: 0) {
                        if index > 0 {
                            Divider()
                        }

                        JSONCell(filtered[index], depth: depth, searchQuery: $searchText)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .searchable(text: $searchText, prompt: "Look up")
        .autocapitalization(.none)
    }
	
	var filtered: [(key: String, value: AnyHashable)] {
		if searchText.isEmpty {
			return keyValues
		}
		else {
			return keyValues.filter { $0.key.localizedCaseInsensitiveContains(searchText) || $0.value.description.localizedCaseInsensitiveContains(searchText) }
		}
	}

    private func calculateJSONDepth(_ object: AnyHashable) -> Int {
        switch object {
        case let dictionary as JSON:
            let depths = dictionary.values.map { calculateJSONDepth($0) }
            return 1 + (depths.max() ?? 0)
        case let array as [AnyHashable]:
            let depths = array.map { calculateJSONDepth($0) }
            return 1 + (depths.max() ?? 0)
        default:
            return 1
        }
    }
}

internal protocol JSONRepresentable {
    var stringValue: String? { get }
}

extension JSONRepresentable {
	var stringValue: String? {
		do {
			let data = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
			return String(data: data, encoding: .utf8)
		}
		catch {
			return nil
		}
	}
}

extension Array: JSONRepresentable where Element: JSONRepresentable {
}

extension JSON: JSONRepresentable {
}

extension JSONTreeView {
    internal init(_ json: JSONRepresentable, prefix key: String = "", depth: Int = 0) {
        switch json {
        case let array as [JSON]:
            self.init(array, prefix: key, depth: depth)
        case let dictionary as JSON:
            self.init(dictionary, depth: depth)
        default:
            self.init(JSON(), depth: depth)
        }
    }
}
