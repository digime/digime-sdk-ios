//
//  LogEntry.swift
//  DigiMeSDKExample
//
//  Created on 17/02/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import DigiMeSDK
import Foundation
import SwiftUI

struct LogEntry: Codable, Identifiable, Hashable {
	enum State: String, Codable {
		case warning
		case success
		case error
	}
	
	enum AttachmentType: String, Codable {
		case none
		case jfs
		case json
		case pdf
		case image
	}
	
	var id = UUID().uuidString
	var state: State = .success
	var date = Date()
	var message: String
	var attachmentType: AttachmentType = .none
	var attachment: Data?
	var attachmentRawMeta: Data?
	var attachmentMappedMeta: Data?
}

extension LogEntry.State {
	var tintColor: Color {
		switch self {
		case .warning:
			return .orange
		case .success:
			return .green
		case .error:
			return .red
		}
	}

	var iconSystemName: String {
		switch self {
		case .warning:
			return "exclamationmark.triangle.fill"
		case .success:
			return "checkmark.circle.fill"
		case .error:
			return "exclamationmark.octagon.fill"
		}
	}
}

extension LogEntry {
	static func mapped(mimeType: MimeType) -> LogEntry.AttachmentType {
		switch mimeType {
		case .applicationJson:
			return .json
		case .applicationPdf:
			return .pdf
		case .imageJpeg, .imageTiff, .imagePng, .imageGif, .imageBmp:
			return .image
		case .textJson:
			return .json
		default:
			return .none
		}
	}
}
