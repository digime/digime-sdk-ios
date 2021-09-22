//
//  ConsentRequestCoordinatingDelegate.swift
//  Genrefy
//
//  Created on 16/07/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import Foundation

protocol ConsentRequestCoordinatingDelegate: CoordinatingDelegate {
    
    func goBack()
    func startConsentRequest()
}
