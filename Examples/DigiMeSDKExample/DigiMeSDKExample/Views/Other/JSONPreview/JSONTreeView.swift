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

    private let keyValues: [(key: String, value: AnyHashable)]

	init(_ dictionary: JSON) {
        self.keyValues = dictionary.sorted { $0.key < $1.key }
    }
    
	init(_ array: [JSON], prefix key: String = "") {
        self.keyValues = array.enumerated().map {
            (key: "\(key)[\($0.offset)]", value: $0.element)
        }
    }

	init(_ source: [(key: String, value: AnyHashable)]) {
        self.keyValues = source
    }
    
	var body: some View {
		ScrollView(.vertical, showsIndicators: true) {
			ForEach(filtered.indices, id: \.self) { index in
				VStack(alignment: .leading) {
					if index > 0 {
						Divider()
					}
					
					JSONCell(self.filtered[index], searchQuery: $searchText)
				}
			}
			.frame(minWidth: 0, maxWidth: .infinity)
			.searchable(text: $searchText, prompt: "Look up")
			.autocapitalization(.none)
			.padding([.top, .bottom], 10)
			.padding(.trailing, 10)
		}
	}
	
	var filtered: [(key: String, value: AnyHashable)] {
		if searchText.isEmpty {
			return keyValues
		}
		else {
			return keyValues.filter { $0.key.localizedCaseInsensitiveContains(searchText) || $0.value.description.localizedCaseInsensitiveContains(searchText) }
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
    internal init(_ json: JSONRepresentable, prefix key: String = "") {
        switch json {
        case let array as [JSON]:
            self.init(array, prefix: key)
        case let dictionary as JSON:
            self.init(dictionary)
        default:
            self.init(JSON())
        }
    }
}
