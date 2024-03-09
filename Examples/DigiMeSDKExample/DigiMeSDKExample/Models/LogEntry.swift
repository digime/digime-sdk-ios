//
//  LogEntry.swift
//  DigiMeSDKExample
//
//  Created on 17/02/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import DigiMeCore
import SwiftData
import SwiftUI

@Model
class LogEntry: Codable {
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
	
	var state: State = State.success
	var date = Date()
	var message: String
	var attachmentType: AttachmentType = AttachmentType.none
    @Attribute(.externalStorage) var attachment: Data?
    @Attribute(.externalStorage) var attachmentRawMeta: Data?
    @Attribute(.externalStorage) var attachmentMappedMeta: Data?

    init(state: State = .success, date: Date = Date(), message: String, attachmentType: AttachmentType = .none, attachment: Data? = nil, attachmentRawMeta: Data? = nil, attachmentMappedMeta: Data? = nil) {
        self.state = state
        self.date = date
        self.message = message
        self.attachmentType = attachmentType
        self.attachment = attachment
        self.attachmentRawMeta = attachmentRawMeta
        self.attachmentMappedMeta = attachmentMappedMeta
    }

    var tintColor: Color {
        switch state {
        case .warning:
            return .orange
        case .success:
            return .green
        case .error:
            return .red
        }
    }

    var iconSystemName: String {
        switch state {
        case .warning:
            return "exclamationmark.triangle.fill"
        case .success:
            return "checkmark.circle.fill"
        case .error:
            return "exclamationmark.octagon.fill"
        }
    }

    enum CodingKeys: String, CodingKey {
        case state, date, message, attachmentType, attachment, attachmentRawMeta, attachmentMappedMeta
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        state = try container.decode(State.self, forKey: .state)
        date = try container.decode(Date.self, forKey: .date)
        message = try container.decode(String.self, forKey: .message)
        attachmentType = try container.decode(AttachmentType.self, forKey: .attachmentType)
        attachment = try container.decodeIfPresent(Data.self, forKey: .attachment)
        attachmentRawMeta = try container.decodeIfPresent(Data.self, forKey: .attachmentRawMeta)
        attachmentMappedMeta = try container.decodeIfPresent(Data.self, forKey: .attachmentMappedMeta)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(state, forKey: .state)
        try container.encode(date, forKey: .date)
        try container.encode(message, forKey: .message)
        try container.encode(attachmentType, forKey: .attachmentType)
        try container.encodeIfPresent(attachment, forKey: .attachment)
        try container.encodeIfPresent(attachmentRawMeta, forKey: .attachmentRawMeta)
        try container.encodeIfPresent(attachmentMappedMeta, forKey: .attachmentMappedMeta)
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
