//
//  AccountSelectionDataSource.swift
//  Genrefy
//
//  Created on 19/07/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import DigiMeSDK
import Foundation

class AccountSelectionDataSource {
    weak var coordinatingDelegate: AccountSelectionCoordinatingDelegate?
    
    private var sortedAccounts: [SourceAccount]
    var selectedAccountIdentifiers: Set<String>
    
    init(accounts: [SourceAccount]) {
        sortedAccounts = accounts
            .sorted(by: { account1, account2 in
                return account1.service.name.compare(account2.service.name, options: .caseInsensitive) == .orderedAscending
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
            return selectedAccountIdentifiers.contains(account.identifier)
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
    
    func itemAt(indexPath: IndexPath) -> AccountSelectionItem? {
        let account = sortedAccounts[indexPath.row]
        let selected = selectedAccountIdentifiers.contains(account.identifier)
        return AccountSelectionItem(uid: account.identifier, account: account, selected: selected)
    }
}
