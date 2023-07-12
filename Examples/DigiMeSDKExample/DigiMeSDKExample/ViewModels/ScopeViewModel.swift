//
//  ScopeViewModel.swift
//  DigiMeSDKExample
//
//  Created on 03/05/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import Combine
import DigiMeSDK
import SwiftUI

class ScopeViewModel: ObservableObject {
    @AppStorage("ActiveServiceContractId") var activeContractId: String = Contracts.prodFinSocMus.identifier
    @AppStorage("SelectedTimeRangeIndex") var selectedTimeRangeIndex: Int = 0
    
    @Published var shouldDisplayModal = false
    @Published var shouldDisplayTimeOption = false
    @Published var shouldDisplayStartDatePicker = false
    @Published var shouldDisplayEndDatePicker = false
    @Published var isScopeModificationAllowed = false
    @Published var isObjectTypeEditingAllowed = true
    @Published var flags: [Bool] = []

    @Published var selectedObjectTypes = Set<Int>()

    @Published var startDateFormatString = ScopeAddView.datePlaceholder
    @Published var endDateFormatString = ScopeAddView.datePlaceholder

    @Published var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    @Published var selectedService: Service?
    @Published var startDate: Date?
    @Published var endDate: Date?
    @Published var readOptions: ReadOptions?

    @Published var selectedDuration = Duration.unlimited()

    @Published var objectTypes: [ServiceObjectType] = []
    @Published var timeRangeTemplates: [TimeRangeTemplate] = TestTimeRangeTemplates.data
    @Published var serviceSections: [ServiceSection] = []
    @Published var linkedAccounts: [LinkedAccount] = []
    @Published var durationOptions: [Duration] = [Duration.unlimited(), 30, 60, 120, 180, 300, 600, 1200]

    var showCustomDateOptions: Bool {
        guard !timeRangeTemplates.isEmpty else {
            return true
        }
        
        return selectedTimeRangeIndex == (timeRangeTemplates.count - 1)
    }
    
    private var preferences = UserPreferences.shared()
    
    func displayScopeEditor() {
        linkedAccounts = preferences.getLinkedAccounts(for: activeContractId)
        readOptions = preferences.readOptions(for: activeContractId)
        selectedDuration = readOptions?.limits?.duration ?? Duration.unlimited()
        refreshObjectTypes()
        flags = linkedAccounts.map { _ in false }
        isScopeModificationAllowed = true
        isObjectTypeEditingAllowed = true
        shouldDisplayModal = true
    }
    
    func refreshObjectTypes() {
        guard
            let groups = readOptions?.scope?.serviceGroups,
            !groups.isEmpty else {
            return
        }
        
        for (index, account) in linkedAccounts.enumerated() {
            for serviceGroup in groups {
                for serviceType in serviceGroup.serviceTypes where serviceType.id == account.service.serviceIdentifier {
                    let serviceObjectTypes = serviceType.serviceObjectTypes
                    if !serviceObjectTypes.isEmpty {
                        linkedAccounts[index].selectedObjectTypeIds = Set(serviceObjectTypes.compactMap { $0.id })
                    }
                }
            }
        }
    }

    func refreshUserInterface() {
        guard let range = timeRangeTemplates[selectedTimeRangeIndex].timeRange else {
            startDateFormatString = ScopeAddView.datePlaceholder
            endDateFormatString = ScopeAddView.datePlaceholder
            return
        }

        switch range {
        case .after(let from):
            startDateFormatString = dateFormatter.string(from: from)
            endDateFormatString = dateFormatter.string(from: Date())
        case let .between(from, to):
            startDateFormatString = dateFormatter.string(from: from)
            endDateFormatString = dateFormatter.string(from: to)
        case .before(let to):
            startDateFormatString = dateFormatter.string(from: Date(timeIntervalSince1970: 0))
            endDateFormatString = dateFormatter.string(from: to)
        case let .last(amount, unit):
            startDateFormatString = dateFormatter.string(from: Calendar.current.date(byAdding: unit.calendarUnit, value: -amount, to: Date())!)
            endDateFormatString = dateFormatter.string(from: Date())
        }
    }

    func completeProcess() {
        refreshDates()
        refreshReadOptions()
        preferences.setLinkedAccounts(newAccounts: linkedAccounts, for: activeContractId)
        preferences.setReadOptions(newReadOptions: readOptions, for: activeContractId)
        shouldDisplayModal = false
    }
    
    func refreshConnectedAccount(for connectedAccountId: UUID, objectTypeId: Int, selected: Bool) {
        if let index = linkedAccounts.firstIndex(where: { $0.id == connectedAccountId }) {
            var connectedAccount = linkedAccounts[index]

            if selected {
                connectedAccount.selectedObjectTypeIds.insert(objectTypeId)
            }
            else {
                connectedAccount.selectedObjectTypeIds.remove(objectTypeId)
            }

            linkedAccounts[index] = connectedAccount
        }
    }
    
    func getDefaultObjectTypes(for section: LinkedAccount) -> [ServiceObjectType] {
        guard let serviceGroupId = section.service.serviceGroupIds.first else {
            return []
        }
        
        return TestServiceObjectTypesByGroups.data.first { $0.id == serviceGroupId }?.items ?? []
    }
    
    func resetSettings() {
        startDate = nil
        endDate = nil
        readOptions = nil
        startDateFormatString = ScopeAddView.datePlaceholder
        endDateFormatString = ScopeAddView.datePlaceholder
        selectedTimeRangeIndex = 0
        selectedObjectTypes = Set<Int>()
        selectedDuration = Duration.unlimited()
        preferences.clearLinkedAccounts(for: activeContractId)
        preferences.clearReadOptions(for: activeContractId)
        
        if isObjectTypeEditingAllowed {
            selectedObjectTypes = Set(objectTypes.map { $0.id })
        }
    }
    
    // MARK: - Private
    
    private func refreshDates() {
        guard
            !showCustomDateOptions,
            let range = timeRangeTemplates[selectedTimeRangeIndex].timeRange else {
            return
        }
        
        switch range {
        case .after(let from):
            startDate = from
            endDate = Date()
        case let .between(from, to):
            startDate = from
            endDate = to
        case .before(let to):
            startDate = Date(timeIntervalSince1970: 0)
            endDate = to
        case let .last(amount, unit):
            startDate = Calendar.current.date(byAdding: unit.calendarUnit, value: -amount, to: Date())
            endDate = Date()
        }
    }
    
    private func refreshReadOptions() {
        guard isScopeModificationAllowed else {
            readOptions = nil
            return
        }
        
        var timeRange: TimeRange!
        if let start = startDate, let end = endDate {
            timeRange = TimeRange.between(from: start, to: end)
        }
        else if let start = startDate {
            timeRange = TimeRange.after(from: start)
        }
        else if let end = endDate {
            timeRange = TimeRange.before(to: end)
        }
                
        if
            let serviceId = selectedService?.identifier,
            let serviceGroupType = generateServiceGroupTypeForAuthorization(with: serviceId) {
            
            // authorize route, when adding your first service
            let limits = Limits(duration: selectedDuration)
            let scope = Scope(serviceGroups: [serviceGroupType], timeRanges: timeRange != nil ? [timeRange] : nil)
            readOptions = ReadOptions(limits: limits, scope: scope)
        }
        else if
            !linkedAccounts.isEmpty,
            let serviceGroupTypes = generateServiceGroupTypeForDataSync() {
            
            // sync trigger, when configuring scoping for all you added services, during data refresh.
            let limits = Limits(duration: selectedDuration)
            let scope = Scope(serviceGroups: serviceGroupTypes, timeRanges: timeRange != nil ? [timeRange] : nil)
            readOptions = ReadOptions(limits: limits, scope: scope)
        }
        else if timeRange != nil {
            let limits = Limits(duration: selectedDuration)
            let scope = Scope(timeRanges: [timeRange])
            readOptions = ReadOptions(limits: limits, scope: scope)
        }
        else {
            readOptions = nil
        }
    }
    
    private func generateServiceGroupTypeForAuthorization(with serviceTypeId: Int) -> ServiceGroupType? {
        guard
            let section = serviceSections.first(where: { $0.items.contains { $0.identifier == serviceTypeId } }),
            let service = section.items.first(where: { $0.identifier == serviceTypeId }) else {
            return nil
        }
        
        let objectTypes = objectTypes.filter { selectedObjectTypes.contains($0.id) }
        
        guard !objectTypes.isEmpty else {
            return nil
        }
        
        let serviceType = ServiceType(identifier: service.serviceIdentifier, objectTypes: objectTypes, name: service.name)
        return ServiceGroupType(identifier: section.serviceGroupId, serviceTypes: [serviceType], name: section.title)
    }
    
    private func generateServiceGroupTypeForDataSync() -> [ServiceGroupType]? {
        var serviceGroups: [ServiceGroupType] = []
        linkedAccounts.forEach { account in
            let objectTypes = account.defaultObjectTypes.filter { account.selectedObjectTypeIds.contains($0.id) }
            if
                !objectTypes.isEmpty,
                let serviceGroupId = account.service.serviceGroupIds.first {
                
                let serviceType = ServiceType(identifier: account.service.serviceIdentifier, objectTypes: objectTypes, name: account.service.name)
                let serviceGroupType = ServiceGroupType(identifier: serviceGroupId, serviceTypes: [serviceType])
                serviceGroups.append(serviceGroupType)
            }
        }
        
        return serviceGroups.isEmpty ? nil : serviceGroups
    }
}
