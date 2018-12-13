//
//  CAObjectTypes.swift
//  DigiMeRepository
//
//  Created on 12/07/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

import Foundation

@objc public enum CAObjectType: Int {
    case account
    
    //Social
    case media = 1
    case post = 2
    case comment = 7
    
    //Finance
    case transaction = 201
    
    //Music
    case track = 400
    case musicAlbum = 401
    case musicPlaylist = 403
    
    //Medical
    case admission = 100
    case arrivalAmbulatory = 101
    case arrivalPrimaryHealth = 102
    case prescription = 103
    case medication = 104
    case diagnosis = 105
    case vaccination = 106
    case allergy = 107
    case arrivalEmergency = 108
    case prescribedItem = 109
    case measurement = 111
    
    //Health + Fitness
    case activity = 300
    case dailyActivitySummary = 301
    case achievement = 302
    case sleep = 303
    case epochSummary = 304
    case stressSummary = 305
    case bodyCompositionSummary = 306
    case moveIqSummary = 307
    
    //Government
    case vehicleTest = 500
    case vehicleRegistration = 501
}
