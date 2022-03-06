//
//  ServicePickerViewController.swift
//  DigiMeSDKExample
//
//  Created on 21/07/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import DigiMeSDK
import UIKit

protocol ServicePickerDelegate: AnyObject {
    func didSelectService(_ service: Service?)
}

class ServicePickerViewController: UITableViewController {
    
    private let sections: [Section]
    
    weak var delegate: ServicePickerDelegate?
    
    private enum ReuseIdentifier {
        static let service = "Services"
        static let scopeSwitch = "ScopeSwitch"
        static let objectTypes = "ObjectTypes"
    }
    
    private struct Section {
        let serviceGroupId: Int
        let title: String
        let items: [Service]
    }
    
    private struct GroupObjectType {
        let serviceGroupId: Int
        let items: [ServiceObjectType]
        
        init(serviceGroupId: Int, items: [ServiceObjectType]) {
            self.serviceGroupId = serviceGroupId
            self.items = items
        }
    }
    
    private var serviceIndexPath: IndexPath?
    private var selectedObjectTypes: [ServiceObjectType] = []
    private var scopeActiveSwitch = UISwitch()
    private var groupObjectTypes: [GroupObjectType] {
        return [
            GroupObjectType(serviceGroupId: 1, items: [
                ServiceObjectType(identifier: 1, name: "Media"),
                ServiceObjectType(identifier: 2, name: "Post"),
                ServiceObjectType(identifier: 7, name: "Comment"),
                ServiceObjectType(identifier: 10, name: "Like"),
                ServiceObjectType(identifier: 12, name: "Media Album"),
                ServiceObjectType(identifier: 15, name: "Social Network User"),
                ServiceObjectType(identifier: 19, name: "Profile"),
            ]),
            GroupObjectType(serviceGroupId: 3, items: [
                ServiceObjectType(identifier: 201, name: "Transaction"),
            ]),
            GroupObjectType(serviceGroupId: 5, items: [
                ServiceObjectType(identifier: 403, name: "Playlist"),
                ServiceObjectType(identifier: 404, name: "Saved Album"),
                ServiceObjectType(identifier: 405, name: "Saved Track"),
                ServiceObjectType(identifier: 406, name: "Play History"),
            ]),
        ]
    }
    
    init(servicesInfo: ServicesInfo) {
        let services = servicesInfo.services
        
        let serviceGroupIds = Set(services.flatMap { $0.serviceGroupIds })
        let serviceGroups = servicesInfo.serviceGroups.filter { serviceGroupIds.contains($0.identifier) }
        
        var sections = [Section]()
        serviceGroups.forEach { group in
            let items = services
                .filter { $0.serviceGroupIds.contains(group.identifier) }
                .sorted { $0.name < $1.name }
            sections.append(Section(serviceGroupId: group.identifier, title: group.name, items: items))
        }
        
        sections.sort { $0.serviceGroupId < $1.serviceGroupId }
        self.sections = sections
        
        super.init(style: .insetGrouped)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        scopeActiveSwitch.addTarget(self, action: #selector(onSwitchValueChanged), for: .valueChanged)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: ReuseIdentifier.service)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: ReuseIdentifier.scopeSwitch)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: ReuseIdentifier.objectTypes)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Service", style: .done, target: self, action: #selector(addService))
    }
    
    private func cellForServiceGroups(_ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.service, for: indexPath)
        let service = sections[indexPath.section].items[indexPath.row]
        cell.textLabel?.text = service.name
        cell.accessoryType = serviceIndexPath == indexPath ? .checkmark : .none
        return cell
    }
    
    private func cellForScopeObjectCell(_ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.objectTypes, for: indexPath)
        cell.accessoryType = selectedObjectTypes.contains { $0.identifier == cell.tag } ? .checkmark : .none
        
        guard let serviceIndexPath = serviceIndexPath else {
            // First load. No selection yet. Load all object types from the top section.
            let objType = groupObjectTypes[0].items[indexPath.row]
            cell.tag = Int(objType.identifier)
            cell.textLabel?.text = objType.name
            return cell
        }
        
        let objType = groupObjectTypes[serviceIndexPath.section].items[indexPath.row]
        cell.tag = Int(objType.identifier)
        cell.textLabel?.text = objType.name
        return cell
    }
    
    private func cellForSwitchCell(_ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.scopeSwitch, for: indexPath)
        cell.accessoryView = scopeActiveSwitch
        cell.textLabel?.text = "Scoping"
        cell.selectionStyle = .none
        return cell
    }
    
    private func finish(service: Service?) {
        DispatchQueue.main.async {
            self.presentingViewController?.dismiss(animated: true) {
                self.delegate?.didSelectService(service)
            }
        }
    }
    
    @objc func onSwitchValueChanged(_ sender: UISwitch) {
        if !sender.isOn {
            selectedObjectTypes = []
        }
        
        tableView.reloadData()
    }
    
    @objc private func cancel() {
       finish(service: nil)
    }
    
    @objc private func addService() {
        guard
            let indexPath = serviceIndexPath,
            !scopeActiveSwitch.isOn || (scopeActiveSwitch.isOn && !selectedObjectTypes.isEmpty) else {
            return
        }
        
        var service = sections[indexPath.section].items[indexPath.row]
        if scopeActiveSwitch.isOn {
            let scope = selectedScope(for: UInt(service.serviceIdentifier), serviceGroup: UInt(service.serviceGroupIds.first ?? 0), objectTypes: selectedObjectTypes)
            service.options = ReadOptions(limits: nil, scope: scope)
        }
        
        finish(service: service)
    }
    
    func selectedScope(for serviceId: UInt, serviceGroup: UInt, objectTypes: [ServiceObjectType]) -> Scope {
        let services = [DigiMeSDK.ServiceType(identifier: serviceId, objectTypes: objectTypes)]
        let groups = [ServiceGroupScope(identifier: serviceGroup, serviceTypes: services)]
        return Scope(serviceGroups: groups, timeRanges: nil)
    }
    
    private func numberOfRowsInScopeSection() -> Int {
        guard let serviceIndexPath = serviceIndexPath else {
            return groupObjectTypes[0].items.count
        }
        
        return groupObjectTypes[serviceIndexPath.section].items.count
    }
}

// MARK: - Table view data source
extension ServicePickerViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count + (scopeActiveSwitch.isOn ? 2 : 1)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0..<sections.count:
            return sections[section].items.count
        case sections.count:
            return 1
        case sections.count + 1:
            return numberOfRowsInScopeSection()
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0..<sections.count:
            return sections[section].title
        case sections.count:
            return "Use Scoping Limitations"
        case sections.count + 1:
            return "Object Types"
        default:
            return ""
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0..<sections.count:
            return cellForServiceGroups(indexPath)
        case sections.count:
            return cellForSwitchCell(indexPath)
        case sections.count + 1:
            return cellForScopeObjectCell(indexPath)
        default:
            return UITableViewCell()
        }
    }
}

// MARK: - Table view delegate
extension ServicePickerViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let previousSelection = serviceIndexPath
        
        // when user select any cell in the table
        // we iterate all cells in Services sections
        for section in 0..<sections.count {
            for row in 0..<tableView.numberOfRows(inSection: section) {
                let nextIndexPathInServiceGroups = IndexPath(row: row, section: section)
                if let nextCell = tableView.cellForRow(at: nextIndexPathInServiceGroups) {
                    
                    // we have reached the selected cell
                    if indexPath == nextIndexPathInServiceGroups {
                        // switch accessory on selection
                        nextCell.accessoryType = nextCell.accessoryType == .none ? .checkmark : .none
                        // remember user's choice
                        serviceIndexPath = indexPath
                    }
                    else if indexPath.section < sections.count {
                        // uncheck if the new selection within the services section
                        nextCell.accessoryType = .none
                    }
                }
            }
        }
        
        if indexPath.section == (sections.count + 1) {
            if let cell = tableView.cellForRow(at: indexPath) {
                // change accessory on the selected cell
                cell.accessoryType = cell.accessoryType == .none ? .checkmark : .none
                
                let contains = selectedObjectTypes.contains { $0.identifier == cell.tag }
                
                if !contains {
                    let newObjectType = groupObjectTypes[indexPath.section - (sections.count + 1)].items[indexPath.row]
                    selectedObjectTypes.append(newObjectType)
                }
                else if contains {
                    selectedObjectTypes.removeAll(where: { $0.identifier == cell.tag })
                }
            }
        }
        
        // reload and update table if user selects a new Service Group section

        if
            indexPath.section < sections.count,
            let previousSelection = previousSelection,
            previousSelection.section != indexPath.section {
            
            selectedObjectTypes = []
            tableView.reloadData()
        }
    }
}
