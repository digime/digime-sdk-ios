//
//  AccountSelectionCoordinatingDelegate.swift
//  Genrefy
//
//  Created on 20/07/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import DigiMeCore
import DigiMeSDK

protocol AccountSelectionCoordinatingDelegate: CoordinatingDelegate {
    
    func selectedAccountsChanged(selectedAccounts: [SourceAccountData])
}
