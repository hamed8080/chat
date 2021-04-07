//
//  AddContactsRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation

@available(*,deprecated , message:"Removed in XX.XX.XX version.")
open class AddContactsRequest {
    
    public let cellphoneNumbers:    [String]
    public let emails:              [String]
    public let firstNames:          [String]
    public let lastNames:           [String]
    public let usernames:           [String]
    
    public let typeCode:            String?
    public let uniqueIds:           [String]
    
    /// Add Contacts with CellPhone numbers
    public init(cellphoneNumbers:   [String],
                emails:             [String],
                firstNames:         [String],
                lastNames:          [String],
                typeCode:           String?,
                uniqueIds:          [String]) {
        
        self.cellphoneNumbers   = cellphoneNumbers
        self.emails             = emails
        self.firstNames         = firstNames
        self.lastNames          = lastNames
        self.usernames          = []
        
        self.typeCode           = typeCode
        self.uniqueIds          = uniqueIds
    }
    
    /// Add Contacts with usernames
    public init(emails:     [String],
                firstNames: [String],
                lastNames:  [String],
                usernames:  [String],
                typeCode:   String?,
                uniqueIds:  [String]) {
        
        self.cellphoneNumbers   = []
        self.emails             = emails
        self.firstNames         = firstNames
        self.lastNames          = lastNames
        self.usernames          = usernames
        
        self.typeCode           = typeCode
        self.uniqueIds          = uniqueIds
    }
    
}

/// MARK: -  this class will be deprecate.  (use this class instead: 'AddContactsRequest')
@available(*,deprecated , message:"Removed in XX.XX.XX version.")
open class AddContactsRequestModel: AddContactsRequest {
    
    
    
}


