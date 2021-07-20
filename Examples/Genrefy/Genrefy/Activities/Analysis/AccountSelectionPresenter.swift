//
//  AccountSelectionPresenter.swift
//  Genrefy
//
//  Created on 19/07/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import UIKit

class AccountSelectionPresenter {
    private var dataSource: AccountSelectionDataSource
    
    init(dataSource: AccountSelectionDataSource) {
        self.dataSource = dataSource
    }
    
    func configure(cell: AccountCell, indexPath: IndexPath) {
        guard let item = dataSource.itemAt(indexPath: indexPath) else {
            return
        }
        
        let isToggleable = canToggleCell(at: indexPath)
        
        cell.setAccountIdentifier(item.account.identifier)
        cell.display(serviceName: item.account.service.name)
        cell.display(accountName: item.account.name)
        cell.display(toggleable: isToggleable, selected: item.selected, animated: false)
        
        if let service = ServiceTypeConverter(name: item.account.service.name) {
            cell.display(icon: UIImage(named: "service_\(service.rawValue)"))
        }
        else {
            cell.display(imageUrl: item.account.service.logo)
        }
        
        cell.setSelectionChangedCallback { uniqueIdentifier in
            _ = self.dataSource.toggleSelection(accountId: uniqueIdentifier)
        }
    }
    
    func toggle(cell: AccountCell, indexPath: IndexPath) {
        guard canToggleCell(at: indexPath) else {
            // Can only toggle if multiple accounts
            return
        }
        
        let selected = self.dataSource.toggleSelection(accountId: cell.accountIdentifier)
        cell.display(toggleable: true, selected: selected, animated: true)
    }
    
    func numberOfRows(section: Int) -> Int {
        return dataSource.numberOfItems(section: section)
    }
    
    func numberOfSections() -> Int {
        return dataSource.numberOfSections
    }
    
    private func canToggleCell(at indexPath:IndexPath) -> Bool {
        return numberOfRows(section: indexPath.section) > 1
    }
}
