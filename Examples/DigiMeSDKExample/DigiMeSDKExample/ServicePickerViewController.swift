//
//  ServicePickerViewController.swift
//  DigiMeSDKExample
//
//  Created on 21/07/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import DigiMeSDK
import Kingfisher
import UIKit

protocol ServicePickerDelegate: AnyObject {
    func didSelectService(_ service: Service?)
}

class ServicePickerViewController: UITableViewController {
    
    private let sections: [Section]
    weak var delegate: ServicePickerDelegate?
    
    private enum ReuseIdentifier {
        static let service = "Service"
    }
    
    private struct Section {
        let title: String
        let items: [Service]
    }
    
    init(servicesInfo: ServicesInfo) {
        let services = servicesInfo.services
        
        let serviceGroupIds = Set(services.flatMap { $0.serviceGroupIds })
        let serviceGroups = servicesInfo.serviceGroups.filter { serviceGroupIds.contains($0.identifier) }
        
        var sections = [Section]()
        serviceGroups.forEach { group in
            let items = services
                .filter { $0.serviceGroupIds.contains(group.identifier) }
                .sorted { $0.name  < $1.name }
            sections.append(Section(title: group.name, items: items))
        }
        
        sections.sort { $0.title < $1.title }
        
        self.sections = sections
        super.init(style: .insetGrouped)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: ReuseIdentifier.service)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].title
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.service, for: indexPath)

        let service = sections[indexPath.section].items[indexPath.row]
        // Configure the cell...
        cell.textLabel?.text = service.name

        return cell
    }
    
    @objc private func cancel() {
       finish(service: nil)
    }
    
    private func finish(service: Service?) {
        DispatchQueue.main.async {
            self.presentingViewController?.dismiss(animated: true) {
                self.delegate?.didSelectService(service)
            }
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let service = sections[indexPath.section].items[indexPath.row]
        finish(service: service)
    }
}
