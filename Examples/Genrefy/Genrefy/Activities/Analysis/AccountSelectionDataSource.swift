//
//  AccountSelectionDataSource.swift
//  Genrefy
//
//  Created on 19/07/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import DigiMeSDK
import Foundation

class AccountSelectionDataSource: Coordinated {
    typealias GenericCoordinatingDelegate = AccountSelectionCoordinatingDelegate
    weak var coordinatingDelegate: GenericCoordinatingDelegate?
    
    private var sortedAccounts: [DMEAccount]
    var selectedAccountIdentifiers: Set<String>
    
    init(accounts: [DMEAccount]) {
        sortedAccounts = accounts
            .sorted(by: { account1, account2 in
                guard
                    let service1 = account1.service?.name,
                    let service2 = account2.service?.name else {
                        return true
                }
                
                return service1.compare(service2, options: .caseInsensitive) == .orderedAscending
            })
        selectedAccountIdentifiers = Set(sortedAccounts.compactMap { $0.identifier })
    }
    
    func toggleSelection(accountId: String) -> Bool {
        let selected = !selectedAccountIdentifiers.contains(accountId)
        if selected {
            selectedAccountIdentifiers.insert(accountId)
        }
        else {
            selectedAccountIdentifiers.remove(accountId)
        }
        
        let selectedAccounts = sortedAccounts.filter { account in
            guard let identifier = account.identifier else {
                return false
            }
            
            return selectedAccountIdentifiers.contains(identifier)
        }
        coordinatingDelegate?.selectedAccountsChanged(selectedAccounts: selectedAccounts)
        
        return selected
    }
    
    func numberOfItems(section: Int) -> Int {        
        switch section {
        case 1:
            return sortedAccounts.count
        default:
            return 1
        }
    }
    
    var numberOfSections: Int {
        return 5
    }
    
    func titleForSection(_ index: Int) -> String? {
        return nil
    }
    
    func itemAt(indexPath: IndexPath) -> AccountSelectionItem? {
        let account = sortedAccounts[indexPath.row]
        guard let identifier = account.identifier else {
            return nil
        }
        
        let selected = selectedAccountIdentifiers.contains(identifier)
        return AccountSelectionItem(uid: identifier, account: account, selected: selected)
    }
}
