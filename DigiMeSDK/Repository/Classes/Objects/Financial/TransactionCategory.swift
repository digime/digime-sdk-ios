//
//  TransactionCategory.swift
//  DigiMeRepository
//
//  Created on 19/09/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

import Foundation

@objc public enum TransactionCategory: Int {
    
    // Expenses
    case automotiveFuel = 2
    case cableSatelliteTelecom = 15
    case cashWithdrawal = 25
    case charitableGiving = 3
    case checkPayment = 33
    case education = 6
    case electronicsGeneralMerchandise = 43
    case entertainmentRecreation = 7
    case gifts = 9
    case groceries = 10
    case healthcareMedical = 11
    case homeImprovement = 13
    case insurance = 14
    case loans = 17
    case mortgage = 18
    case officeExpenses = 45
    case otherExpenses = 19
    case personalFamily = 20
    case pets = 42
    case postageShipping = 104
    case rent = 21
    case restaurants = 22
    case serviceChargeFees = 24
    case servicesSupplies = 16
    case subscriptionsRenewals = 108
    case taxes = 37
    case travel = 23
    case utilities = 39
    
    // Income
    case deposits = 27
    case expensesReimbursements = 114
    case interestIncome = 96
    case investmentRetirementIncome = 30
    case otherIncome = 32
    case refundsAdjustments = 227
    case rewards = 225
    case salaryRegularIncome = 29
    case salesServiceIncome = 92
    
    // Transfer
    case creditCardPayments = 26
    case savings = 40
    case securitiesTrading = 36
    case transfers = 28
    
    // Deferred Compensation
    case retirementContributions = 41
    
    // General
    case uncategorized = 1
    
    static func from(_ rawValue: Int) -> TransactionCategory {
        if let category = TransactionCategory(rawValue: rawValue) {
            return category
        }
        
        // Legacy category IDs
        switch rawValue {
        case 4, 5:
            return .personalFamily
        case 8:
            return .automotiveFuel
        case 12:
            return .homeImprovement
        case 31:
            return .investmentRetirementIncome
        case 34:
            return .entertainmentRecreation
        case 35, 112:
            return .otherExpenses
        case 38:
            return .cableSatelliteTelecom
        case 44:
            return .electronicsGeneralMerchandise
        case 94, 96:
            return .salesServiceIncome
        case 100, 102, 106, 110:
            return .officeExpenses
        default:
            return .uncategorized
        }
    }
}
