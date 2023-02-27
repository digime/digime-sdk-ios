//
//  HighlightedTextView.swift
//  DigiMeSDKExample
//
//  Created on 20/02/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import SwiftUI

struct HighlightedTextView: View {
	/// True when the current [text] needs more than one line to render
	@State private var isTruncated = false
	
	/// The text rendered by current View
	let text: String
	/// The textPart to "highlight" if [text] contains it
	var textPart: String?
	/// The <Text> views created inside the current view inherits Text params defined for self (HighlightedText) like font, underline, etc
	/// Color used for view background when text value contans textPart value
	var textPartBgColor = Color.blue
	/// Font size used to determine if the current text needs more than one line for render
	var fontSize: CGFloat = 18
	/// Max characters length allowed for one line, if exceeds a new line will be added
	var maxLineLength = 25
	/// False to disable multiline drawing
	var multilineEnabled = true
	
	var body: some View {
		guard let textP = textPart, !textP.isEmpty else {
			// 1. Default case, [textPart] is null or empty
			return AnyView(Text(text))
		}
		
		let matches = collectRegexMatches(textP)
		if matches.isEmpty {
			// 2. [textPart] has a value but is not found in the [text] value
			return AnyView(Text(text))
		}
		
		// 3. There is at least one match for [textPart] in [text]
		let textParts = collectTextParts(matches, textP)
		if multilineEnabled && isTruncated {
			// 4. The current [text] needs more than one line to render
			return AnyView(renderTruncatedContent(collectLineTextParts(textParts)))
		}
		
		// 5. The current [text] can be rendered in one line
		return AnyView(renderOneLineContent(textParts))
	}
	
	@ViewBuilder
	private func renderOneLineContent(_ textParts: [TextPartOption]) -> some View {
		HStack(alignment: .top, spacing: 0) {
			ForEach(textParts) { item in
				if item.highlighted {
					Text(item.textPart)
						.frame(height: 30, alignment: .leading)
						.background(textPartBgColor)
				}
				else {
					Text(item.textPart)
						.frame(height: 30, alignment: .leading)
				}
			}
		}.background(GeometryReader { geometry in
			if multilineEnabled {
				Color.clear.onAppear {
					self.determineTruncation(geometry)
				}
			}
		})
	}
	
	@ViewBuilder
	private func renderTruncatedContent(_ lineTextParts: [TextPartsLine]) -> some View {
		VStack(alignment: .leading, spacing: 0) {
			ForEach(Array(lineTextParts)) { lineTextPartsItem in
				HStack(alignment: .top, spacing: 0) {
					ForEach(lineTextPartsItem.textParts) { textPartItem in
						if textPartItem.highlighted {
							Text(textPartItem.textPart)
								.frame(height: 25, alignment: .leading)
								.background(textPartBgColor)
						}
						else {
							Text(textPartItem.textPart)
								.frame(height: 25, alignment: .leading)
						}
					}
				}
			}
		}
	}
	
	private func charCount(_ textParts: [TextPartOption]) -> Int {
		return textParts.reduce(0) { partialResult, textPart in
			partialResult + textPart.textPart.count
		}
	}
	
	private func collectLineTextParts(_ currTextParts: [TextPartOption]) -> [TextPartsLine] {
		var textParts = currTextParts
		var lineTextParts: [TextPartsLine] = []
		var currTextParts: [TextPartOption] = []
		while !textParts.isEmpty {
			let currItem = textParts.removeFirst()
			let extraChars = charCount(currTextParts) + (currItem.textPart.count - 1) - maxLineLength
			if extraChars > 0 && (currItem.textPart.count - 1) - extraChars > 0 {
				let endIndex = currItem.textPart.index(currItem.textPart.startIndex, offsetBy: (currItem.textPart.count - 1) - extraChars)
				currTextParts.append(
					TextPartOption(
						index: currTextParts.count,
						textPart: String(currItem.textPart[currItem.textPart.startIndex..<endIndex]),
						highlighted: currItem.highlighted
					)
				)
				lineTextParts.append(TextPartsLine(textParts: currTextParts))
				
				currTextParts = []
				currTextParts.append(TextPartOption(index: currTextParts.count, textPart: String(currItem.textPart[endIndex..<currItem.textPart.index(endIndex, offsetBy: extraChars)]), highlighted: currItem.highlighted))
			}
			else {
				currTextParts.append(currItem.copy(index: currTextParts.count))
			}
		}
		if !currTextParts.isEmpty {
			lineTextParts.append(TextPartsLine(textParts: currTextParts))
		}
		
		return lineTextParts
	}
	
	private func collectTextParts(_ matches: [NSTextCheckingResult], _ textPart: String) -> [TextPartOption] {
		var textParts: [TextPartOption] = []
		
		// 1. Adding start non-highlighted text if exists
		if let firstMatch = matches.first, firstMatch.range.location > 0 {
			textParts.append(
				TextPartOption(
					index: textParts.count,
					textPart: String(text[text.startIndex..<text.index(text.startIndex, offsetBy: firstMatch.range.location)]),
					highlighted: false
				)
			)
		}
		
		// 2. Adding highlighted text matches and non-highlighted texts in-between
		var lastMatchEndIndex: String.Index?
		for (index, match) in matches.enumerated() {
			let startIndex = text.index(text.startIndex, offsetBy: match.range.location)
			if (match.range.location + textPart.count) > text.count {
				lastMatchEndIndex = text.endIndex
			}
			else {
				lastMatchEndIndex = text.index(startIndex, offsetBy: textPart.count)
			}
			// Adding highlighted string
			textParts.append(
				TextPartOption(
					index: textParts.count,
					textPart: String(text[startIndex..<lastMatchEndIndex!]),
					highlighted: true
				)
			)
			
			if (matches.count > index + 1 ) && (matches[index + 1].range.location != (match.range.location + textPart.count)) {
				// There is a non-highlighted string between highlighted strings
				textParts.append(
					TextPartOption(
						index: textParts.count,
						textPart: String(text[lastMatchEndIndex!..<text.index(text.startIndex, offsetBy: matches[index + 1].range.location)]),
						highlighted: false
					)
				)
			}
		}
		
		// 3. Adding end non-highlighted text if exists
		if let lastMatch = matches.last, lastMatch.range.location < text.count {
			textParts.append(
				TextPartOption(
					index: textParts.count,
					textPart: String(text[lastMatchEndIndex!..<text.endIndex]),
					highlighted: false
				)
			)
		}
		
		return textParts
	}
	
	private func collectRegexMatches(_ match: String) -> [NSTextCheckingResult] {
		let pattern = NSRegularExpression.escapedPattern(for: match)
			.trimmingCharacters(in: .whitespacesAndNewlines)
			.folding(options: .regularExpression, locale: .current)
		
		// swiftlint:disable:next force_try
		return try! NSRegularExpression(pattern: pattern, options: .caseInsensitive).matches(in: text, options: .withTransparentBounds, range: NSRange(location: 0, length: text.count))
	}
	
	private func determineTruncation(_ geometry: GeometryProxy) {
		// Calculate the bounding box we'd need to render the
		// text given the width from the GeometryReader.
		let total = self.text.boundingRect(
			with: CGSize(
				width: geometry.size.width,
				height: .greatestFiniteMagnitude
			),
			options: .usesLineFragmentOrigin,
			attributes: [.font: UIFont.systemFont(ofSize: fontSize)],
			context: nil
		)
		
		if total.size.height > geometry.size.height {
			isTruncated = true
		}
		else {
			isTruncated = false
		}
	}
	
	private struct TextPartOption: Identifiable {
		let index: Int
		let textPart: String
		let highlighted: Bool
		
		var id: String { "\(index)_\(textPart)" }
		
		func copy(index: Int? = nil, textPart: String? = nil, highlighted: Bool? = nil) -> TextPartOption {
			return TextPartOption(
				index: index ?? self.index,
				textPart: textPart ?? self.textPart,
				highlighted: highlighted ?? self.highlighted
			)
		}
	}
	
	private struct TextPartsLine: Identifiable {
		let textParts: [TextPartOption]
		
		var id: String {
			textParts.reduce(into: "") { partialResult, textPartOption in
				partialResult += "_\(textPartOption.id)"
			}
		}
	}
}

struct HighlightedText_Previews: PreviewProvider {
	static var previews: some View {
		HighlightedTextView(text: "False to disable multiline drawing")
	}
}
