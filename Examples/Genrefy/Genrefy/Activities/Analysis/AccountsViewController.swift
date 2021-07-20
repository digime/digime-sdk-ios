//
//  AccountsViewController.swift
//  Genrefy
//
//  Created on 18/07/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import UIKit

protocol AccountsViewCoordinatingDelegate: CoordinatingDelegate {
    func reset()
}

class AccountsViewController: UIViewController, Storyboarded {
    var coordinatingDelegate: AccountsViewCoordinatingDelegate?
    
    static var storyboardName = "Analysis"
    
    @IBOutlet weak var tableView: UITableView!
    var presenter: AccountSelectionPresenter!
    
    private enum Section: Int {
        case accountTitle, accounts, privacyTitle, receipts, reset
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let headerNib = UINib.init(nibName: "StartOverFooterView", bundle: Bundle.main)
        tableView.register(headerNib, forHeaderFooterViewReuseIdentifier: "StartOverFooterView")
    }
}

// MARK: - UITableViewDataSource
extension AccountsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return presenter.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfRows(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        
        switch (section) {
        case .accountTitle:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SectionTitleDetailTableViewCell", for: indexPath) as! SectionTitleDetailTableViewCell
            cell.sectionTitleLabel.text = "Analysis"
            let shouldShowSubtitle = tableView.numberOfRows(inSection: Section.accounts.rawValue) > 1
            cell.sectionSubtitleLabel.text = shouldShowSubtitle ? "Decide which accounts are analysed" : nil
            return cell
        case .accounts:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AccountCell", for: indexPath)
            if let cell = cell as? AccountTableViewCell {
                presenter.configure(cell: cell, indexPath: indexPath)
            }
            return cell
        case .privacyTitle:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SectionTitleTableViewCell", for: indexPath) as! SectionTitleTableViewCell
            cell.sectionTitleLabel.text = "Privacy"
            return cell
        case .receipts:
            return tableView.dequeueReusableCell(withIdentifier: "ReceiptsLinkTableViewCell", for: indexPath)
        case .reset:
            let cell = tableView.dequeueReusableCell(withIdentifier: "StartOverTableViewCell", for: indexPath) as! StartOverTableViewCell
            cell.coordinatingDelegate = coordinatingDelegate
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension AccountsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Allow user to select whole cell rather than having to toggle accessory
        if let cell = tableView.cellForRow(at: indexPath) as? AccountTableViewCell {
            presenter.toggle(cell: cell, indexPath: indexPath)
        }
    }
}
