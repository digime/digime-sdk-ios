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
    
    private var sortedAccounts: [SourceAccountData]
    var selectedAccountIdentifiers: Set<String>
    
    init(accounts: [SourceAccountData]) {
        sortedAccounts = accounts
            .sorted(by: { account1, account2 in
                return account1.serviceTypeName.compare(account2.serviceTypeName, options: .caseInsensitive) == .orderedAscending
            })
        selectedAccountIdentifiers = Set(sortedAccounts.compactMap { $0.id })
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
            return selectedAccountIdentifiers.contains(account.id)
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
        let selected = selectedAccountIdentifiers.contains(account.id)
        return AccountSelectionItem(uid: account.id, account: account, selected: selected)
    }
}
