//
//  DMERepositoryDelegate.swift
//  DigiMeRepository
//
//  Created on 11/07/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

import Foundation

@objc public protocol DMERepositoryDelegate: NSObjectProtocol {
    func repositoryDidError(error: Error)
    
    func repositoryDidFinishUpdate()
    
    func repositoryUpdated(progress: Int)
}
