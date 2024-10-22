//
//  FileResponse.swift
//  DigiMeSDK
//
//  Created on 11/08/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import DigiMeCore
import Foundation

struct FileResponse: Decodable {
    let data: Data
    let info: FileInfo
}
