//
//  SourceAccountData.swift
//  DigiMeSDK
//
//  Created on 14/07/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import Foundation

public enum AccountType: String, Codable, Equatable {
    case user = "USER"
    case admin = "ADMIN"
    case event = "EVENT"
    case group = "GROUP"
    case bank = "BANK"
    case creditCard = "CREDIT_CARD"
    case imported = "IMPORTED"
    case investment = "INVESTMENT"
    case insurance = "INSURANCE"
    case loan = "LOAN"
    case reward = "REWARD"
    case bill = "BILL"
    case push = "PUSH"
}

public struct SourceAccountData: Codable, Identifiable {
    public var identifier: UUID
    
    public struct AccessTokenStatus: Codable {
        public let authorized: Bool
        public let expiresAt: Double?
        
        public init(authorized: Bool, expiresAt: Double?) {
            self.authorized = authorized
            self.expiresAt = expiresAt
        }
    }
    
    public let reference: String
    public let type: AccountType
    public let createdDate: Double
    public let id: String
    public let serviceGroupId: Int
    public let serviceGroupName: String
    public let serviceTypeId: Int
    public let serviceTypeName: String
    public let serviceTypeReference: String
    public let sourceId: Int
    public let updatedDate: Double
    
    public let accessTokenStatus: AccessTokenStatus?
    public let providerFavIcon: String?
    public let providerLogo: String?
    public let serviceProviderId: Int?
    public let serviceProviderName: String?
    public let serviceProviderReference: String?
    public let username: String?
    
    public init(identifier: UUID, id: String, reference: String, type: AccountType, createdDate: Double, serviceGroupId: Int, serviceGroupName: String, serviceTypeId: Int, serviceTypeName: String, serviceTypeReference: String, sourceId: Int, updatedDate: Double, accessTokenStatus: AccessTokenStatus?, providerFavIcon: String?, providerLogo: String?, serviceProviderId: Int?, serviceProviderName: String?, serviceProviderReference: String?, username: String?) {
        self.identifier = identifier
        self.id = id
        self.reference = reference
        self.type = type
        self.createdDate = createdDate
        self.serviceGroupId = serviceGroupId
        self.serviceGroupName = serviceGroupName
        self.serviceTypeId = serviceTypeId
        self.serviceTypeName = serviceTypeName
        self.serviceTypeReference = serviceTypeReference
        self.sourceId = sourceId
        self.updatedDate = updatedDate
        self.accessTokenStatus = accessTokenStatus
        self.providerFavIcon = providerFavIcon
        self.providerLogo = providerLogo
        self.serviceProviderId = serviceProviderId
        self.serviceProviderName = serviceProviderName
        self.serviceProviderReference = serviceProviderReference
        self.username = username
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.identifier = try container.decodeIfPresent(UUID.self, forKey: .identifier) ?? UUID()
        self.id = try container.decode(String.self, forKey: .id)
        self.reference = try container.decode(String.self, forKey: .reference)
        self.type = try container.decode(AccountType.self, forKey: .type)
        self.createdDate = try container.decode(Double.self, forKey: .createdDate)
        self.serviceGroupId = try container.decode(Int.self, forKey: .serviceGroupId)
        self.serviceGroupName = try container.decode(String.self, forKey: .serviceGroupName)
        self.serviceTypeId = try container.decode(Int.self, forKey: .serviceTypeId)
        self.serviceTypeName = try container.decode(String.self, forKey: .serviceTypeName)
        self.serviceTypeReference = try container.decode(String.self, forKey: .serviceTypeReference)
        self.sourceId = try container.decode(Int.self, forKey: .sourceId)
        self.updatedDate = try container.decode(Double.self, forKey: .updatedDate)
        self.accessTokenStatus = try container.decodeIfPresent(SourceAccountData.AccessTokenStatus.self, forKey: .accessTokenStatus)
        self.providerFavIcon = try container.decodeIfPresent(String.self, forKey: .providerFavIcon)
        self.providerLogo = try container.decodeIfPresent(String.self, forKey: .providerLogo)
        self.serviceProviderId = try container.decodeIfPresent(Int.self, forKey: .serviceProviderId)
        self.serviceProviderName = try container.decodeIfPresent(String.self, forKey: .serviceProviderName)
        self.serviceProviderReference = try container.decodeIfPresent(String.self, forKey: .serviceProviderReference)
        self.username = try container.decodeIfPresent(String.self, forKey: .username)
    }
    
    public func getAccountId() -> String {
        let array = id.split(separator: "_")
        
        guard
            array.count == 2,
            let accountId = array.last else {
            return reference
        }
        
        return String(accountId)
    }
}
