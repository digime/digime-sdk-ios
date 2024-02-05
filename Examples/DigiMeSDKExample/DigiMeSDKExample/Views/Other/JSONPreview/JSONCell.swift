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
    private var depth: Int

    internal init(_ keyValue: (key: String, value: AnyHashable), depth: Int, searchQuery: Binding<String>) {
        self.init(key: keyValue.key, value: keyValue.value, depth: depth, searchQuery: searchQuery)
    }

    init(key: String, value: AnyHashable, depth: Int, searchQuery: Binding<String>) {
        self.key = key
        self.rawValue = value
        self.depth = depth
        _searchQuery = searchQuery
    }

	var body: some View {
		specificView()
            .frame(maxWidth: .infinity)
            .contextMenu {
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
            if let data = Data(base64Encoded: string),
               let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) {
                if let json = jsonObject as? JSON {
                    UIPasteboard.general.string = json.stringValue
                }
                else if let jsonArray = jsonObject as? [JSON] {
                    UIPasteboard.general.string = jsonArray.stringValue
                }
                else {
                    // If decoded data is not JSON, use the decoded string
                    UIPasteboard.general.string = String(data: data, encoding: .utf8)
                }
            }
            else {
                // If it's not Base64 encoded, use the original string
                UIPasteboard.general.string = string
            }
        default:
            UIPasteboard.general.string = nil
        }
    }

	private func specificView() -> some View {
        HStack(alignment: .top, spacing: 8) {
            // Add vertical lines based on depth
            Rectangle()
                .frame(width: 2)
                .foregroundColor(Color.gray)
                .padding(.leading, 4)

            // Use a Group to encapsulate the switch statement
            VStack {
                switch rawValue {
                case let array as [JSON]:
                    // Create a JSONTreeView for the array with incremented depth
                    keyValueView(treeView: JSONTreeView(array, prefix: key, depth: depth + 1))

                case let dictionary as JSON:
                    // Create a JSONTreeView for the dictionary with incremented depth
                    keyValueView(treeView: JSONTreeView(dictionary, prefix: key, depth: depth + 1))

                case let number as NSNumber:
                    // Handle number, potentially formatting dates
                    leafViewForNumber(number)

                case let string as String:
                    // Handle string, potentially decoding JSON or other formats
                    leafViewForString(string)

                case is NSNull:
                    // Handle null value
                    leafView("null")

                default:
                    leafView("No data")
                    
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity)
	}
	
    private func leafViewForNumber(_ number: NSNumber) -> AnyView {
        if key.lowercased().contains("date") {
            let date = Date(timeIntervalSince1970: number.doubleValue / 1000)
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            formatter.timeStyle = .short
            return AnyView(leafView(formatter.string(from: date)))
        } 
        else {
            return AnyView(leafView(number.stringValue))
        }
    }

    private func leafViewForString(_ string: String) -> AnyView {
        if let data = Data(base64Encoded: string) {
            // Handle potential JSON or other formats encoded in the string
            return handleEncodedStringData(data)
        } 
        else {
            return AnyView(leafView(string))
        }
    }

    private func handleEncodedStringData(_ data: Data) -> AnyView {
        if 
            let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
            let json = jsonObject as? JSON {

            return AnyView(keyValueView(treeView: JSONTreeView(json, prefix: key, depth: depth + 1)))
        }
        else if PDFKitView.isPDF(data: data) {
            return AnyView(PDFKitView(data: data)
                        .frame(height: 300))
        }
        else if let image = UIImage(data: data) {
            return AnyView(Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .edgesIgnoringSafeArea(.all))
        }
        else {
            return AnyView(leafView("Invalid Data"))
        }
    }

	private func leafView(_ stringValue: String) -> some View {
		VStack(alignment: .leading, spacing: 0) {
			HStack(alignment: .center) {
				HighlightedTextView(text: key, textPart: searchQuery, textPartBgColor: .accentColor, multilineEnabled: false)
				Spacer()
			}
			
			HighlightedTextView(text: stringValue, textPart: searchQuery, textPartBgColor: .accentColor, multilineEnabled: false)
				.foregroundColor(Color.gray)
				.lineSpacing(0)
		}
        .padding(.vertical)
        .padding(.trailing)
        .frame(minHeight: 50)
	}
	
	private func toggle() {
		self.isOpen.toggle()
		withAnimation(.linear(duration: 0.1)) {
			self.isRotate.toggle()
		}
	}
	
	private func keyValueView(treeView valueView: JSONTreeView) -> some View {
		VStack(alignment: .leading, spacing: 0) {
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
                .padding(.vertical)
                .frame(minHeight: 50)
			}
			
			if isOpen {
				Divider()
				valueView
			}
		}
	}
}
