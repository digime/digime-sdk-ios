//
//  HealthDataExportFile.swift
//  DigiMeSDKExample
//
//  Created on 21/05/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

#if canImport(SwiftData)
import Foundation
import SwiftData

@available(iOS 17.0, *)
@Model
class HealthDataExportFile: Identifiable {
    @Attribute(.unique) var id: UUID
    var typeIdentifier: String
    var fileName: String
    var createdDate: Date
    var dataStartDate: Date
    var dataEndDate: Date
    var fileURL: URL
    var itemCount: Int
    var uploadState: Int

    init(typeIdentifier: String, fileName: String, createdDate: Date, dataStartDate: Date, dataEndDate: Date, fileURL: URL, itemCount: Int, state: UploadState = .idle) {
        self.id = UUID()
        self.typeIdentifier = typeIdentifier
        self.fileName = fileName
        self.createdDate = createdDate
        self.dataStartDate = dataStartDate
        self.dataEndDate = dataEndDate
        self.fileURL = fileURL
        self.itemCount = itemCount
        self.uploadState = state.rawValue
    }
}

@available(iOS 17.0, *)
extension HealthDataExportFile: Equatable {
    static func == (lhs: HealthDataExportFile, rhs: HealthDataExportFile) -> Bool {
        return lhs.typeIdentifier == rhs.typeIdentifier &&
        lhs.fileName == rhs.fileName &&
        lhs.createdDate == rhs.createdDate &&
        lhs.dataStartDate == rhs.dataStartDate &&
        lhs.dataEndDate == rhs.dataEndDate &&
        lhs.fileURL == rhs.fileURL &&
        lhs.itemCount == rhs.itemCount
    }
}

struct HealthDataExportFileHandler {
    let id: UUID
    let typeIdentifier: String
    let fileName: String
    let data: Data
    var uploadState: UploadState
}
#endif
