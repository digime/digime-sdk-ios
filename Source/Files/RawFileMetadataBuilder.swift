//
//  RawFileMetadataBuilder.swift
//  DigiMeSDK
//
//  Created on 28/07/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation

/// Allows metadata for raw files, which will be written to user's library,
/// to be built up.
public final class RawFileMetadataBuilder {
    let mimeType: MimeType
    let accounts: [String]
    private(set) var reference: [String]?
    private(set) var tags: [String]?
    private(set) var contractId: String?
    private(set) var appId: String?
    private(set) var objectTypes: [RawFileMetadata.ObjectType]?
    private(set) var serviceGroups: [Int]?
    private(set) var providerName: String?
    
    /// Initializes builder with mandatory values
    /// - Parameters:
    ///   - mimeType: The MIME type of the data being written
    ///   - accounts: An array of user accounts associated with data being written
    public init(mimeType: MimeType, accounts: [String]) {
        self.mimeType = mimeType
        self.accounts = accounts
    }
    
    /// Adds references associated with data being written. Typically this would include the name of the file.
    /// - Parameter value: An array of reference values
    /// - Returns: The updated builder
    public func reference(_ value: [String]) -> RawFileMetadataBuilder {
        reference = value
        return self
    }
    
    /// Adds tags describing the data being written
    /// - Parameter value: An array of tag values
    /// - Returns: The updated builder
    public func tags(_ value: [String]) -> RawFileMetadataBuilder {
        tags = value
        return self
    }
    
    /// Adds the identifier of the respective contract which can read the written data
    /// - Parameter value: The contract identifier
    /// - Returns: The updated builder
    public func contractId(_ value: String) -> RawFileMetadataBuilder {
        contractId = value
        return self
    }
    
    /// Adds the identifier of the application containing the respective contract which can read the written data
    /// - Parameter value: The application identifier
    /// - Returns: The updated builder
    public func appId(_ value: String) -> RawFileMetadataBuilder {
        appId = value
        return self
    }
    
    /// Adds the name of the provider writing the data
    /// - Parameter value: The provider name
    /// - Returns: The updated builder
    public func providerName(_ value: String) -> RawFileMetadataBuilder {
        providerName = value
        return self
    }
    
    /// Adds object types describing data being written
    /// - Parameter value: The object types
    /// - Returns: The updated builder
    public func objectTypes(_ value: [RawFileMetadata.ObjectType]) -> RawFileMetadataBuilder {
        objectTypes = value
        return self
    }
    
    /// Adds identifiers of service groups associated with data being written.
    /// See https://developers.digi.me/reference-objects#service-group for list of service groups.
    /// - Parameter value: The service group identifiers
    /// - Returns: The updated builder
    public func serviceGroups(_ value: [Int]) -> RawFileMetadataBuilder {
        serviceGroups = value
        return self
    }
    
    /// Builds the metadata for the data file being written
    /// - Returns: The built metadata
    public func build() -> RawFileMetadata {
        RawFileMetadata(builder: self)
    }
}
