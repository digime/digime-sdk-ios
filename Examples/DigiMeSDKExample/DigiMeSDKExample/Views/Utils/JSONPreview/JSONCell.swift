//
//  JSONCell.swift
//  DigiMeSDKExample
//
//  Created on 17/02/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import SwiftUI

struct JSONCell: View {
	@Binding var searchQuery: String
	@State private var isOpen = false
	@State private var isRotate = false
	
	private let key: String
	private let rawValue: AnyHashable

	internal init(_ keyValue: (key: String, value: AnyHashable), searchQuery: Binding<String>) {
		self.init(key: keyValue.key, value: keyValue.value, searchQuery: searchQuery)
	}
	
	init(key: String, value: AnyHashable, searchQuery: Binding<String>) {
		self.key = key
		self.rawValue = value
		_searchQuery = searchQuery
	}
	
	var body: some View {
		specificView().padding(.leading, 10).contextMenu {
			Button(action: copyValue) {
				Text("Copy Value")
			}
		}
	}
	
	func copyValue() {
		switch rawValue {
		case let array as [JSON]:
			UIPasteboard.general.string = (array as JSONRepresentable).stringValue
		case let dictionary as JSON:
			UIPasteboard.general.string = (dictionary as JSONRepresentable).stringValue
		case let number as NSNumber:
			UIPasteboard.general.string = number.stringValue
		case let string as String:
			UIPasteboard.general.string = string
		default:
			UIPasteboard.general.string = nil
		}
	}
	
	private func specificView() -> some View {
		switch rawValue {
		case let array as [JSON]: // NSArray
			return AnyView(keyValueView(treeView: JSONTreeView(array, prefix: key)))
		case let dictionary as JSON: // NSDictionary
			return AnyView(keyValueView(treeView: JSONTreeView(dictionary, prefix: key)))
		case let number as NSNumber: // NSNumber
			return AnyView(leafView(number.stringValue))
		case let string as String: // NSString
			return AnyView(leafView(string))
		case is NSNull: // NSNull
			return AnyView(leafView("null"))
		default:
			fatalError("An error occured when mapping object types.")
		}
	}
	
	private func leafView(_ stringValue: String) -> some View {
		VStack(alignment: .leading, spacing: 4) {
			HStack(alignment: .center) {
				HighlightedTextView(text: key, textPart: searchQuery, textPartBgColor: .accentColor, multilineEnabled: false)
				Spacer()
			}
			
			HighlightedTextView(text: stringValue, textPart: searchQuery, textPartBgColor: .accentColor, multilineEnabled: false)
				.padding(.bottom, 2)
				.foregroundColor(Color.gray)
				.lineSpacing(0)
		}
		.padding(.vertical, 5)
		.padding(.trailing, 10)
	}
	
	private func toggle() {
		self.isOpen.toggle()
		withAnimation(.linear(duration: 0.1)) {
			self.isRotate.toggle()
		}
	}
	
	private func keyValueView(treeView valueView: JSONTreeView) -> some View {
		VStack(alignment: .leading) {
			Button(action: toggle) {
				HStack(alignment: .center) {
					Image(systemName: "arrowtriangle.right.fill")
						.resizable()
						.frame(width: 10, height: 10, alignment: .center)
						.foregroundColor(Color.gray)
						.rotationEffect(Angle(degrees: isRotate ? 90 : 0))
					
					Text(key)
					Spacer()
				}
			}
			
			if isOpen {
				Divider()
				valueView
			}
		}
	}
}
