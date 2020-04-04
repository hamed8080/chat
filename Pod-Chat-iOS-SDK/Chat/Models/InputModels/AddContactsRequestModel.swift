//
//  AddContactsRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation

open class AddContactRequestModel {
    
    public let cellphoneNumber: String?
    public let email:           String?
    public let firstName:       String?
    public let lastName:        String?
    public let username:        String?
    
    public let typeCode:        String?
    public let uniqueId:        String
    
    public init(cellphoneNumber:    String?,
                email:              String?,
                firstName:          String?,
                lastName:           String?,
                typeCode:           String?,
                uniqueId:           String?) {
        
        self.cellphoneNumber    = cellphoneNumber
        self.email              = email
        self.firstName          = firstName
        self.lastName           = lastName
        self.username           = nil
        
        self.typeCode           = typeCode
        self.uniqueId           = uniqueId ?? UUID().uuidString
    }
    
    public init(email:              String?,
                firstName:          String?,
                lastName:           String?,
                username:           String?,
                typeCode:           String?,
                uniqueId:           String?) {
        
        self.cellphoneNumber    = nil
        self.email              = email
        self.firstName          = firstName
        self.lastName           = lastName
        self.username           = username
        
        self.typeCode           = typeCode
        self.uniqueId           = uniqueId ?? UUID().uuidString
    }
    
}


open class AddContactsRequestModel {
    
    public let cellphoneNumbers:    [String]
    public let emails:              [String]
    public let firstNames:          [String]
    public let lastNames:           [String]
//    public let usernames:           [String]
    
    public let typeCode:            String?
    public let uniqueIds:           [String]
    
    public init(cellphoneNumbers:   [String],
                emails:             [String],
                firstNames:         [String],
                lastNames:          [String],
//                usernames:          [String],
                typeCode:           String?,
                uniqueIds:          [String]) {
        
        self.cellphoneNumbers   = cellphoneNumbers
        self.emails             = emails
        self.firstNames         = firstNames
        self.lastNames          = lastNames
//        self.usernames          = usernames
        
        self.typeCode           = typeCode
        self.uniqueIds          = uniqueIds
    }
    
}
