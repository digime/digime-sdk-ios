//
//  UploadState.swift
//  DigiMeSDKExample
//
//  Created on 22/05/2024.
//  Copyright © 2024 digi.me Limited. All rights reserved.
//

import Foundation

/// Represents the state of an upload process.
enum UploadState: Int, Codable {
    case idle = 1      /// Upload has not started yet.
    case uploading     /// Upload is currently in progress.
    case uploaded      /// Upload has completed successfully.
    case error         /// An error occurred during the upload.
}
