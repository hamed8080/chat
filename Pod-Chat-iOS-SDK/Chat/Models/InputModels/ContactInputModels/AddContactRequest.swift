//
//  AddContactRequestModel.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 2/2/1399 AP.
//  Copyright © 1399 Mahyar Zhiani. All rights reserved.
//

import Foundation

open class AddContactRequest {
    
    public var cellphoneNumber:    String?
    public var email:              String?
    public var firstName:          String?
    public var lastName:           String?
    public var ownerId:            Int?
    public var username:           String?

    public var typeCode:           String?
    public var uniqueId:           String
    
    /// Add Contact with CellPhone number
    public init(cellphoneNumber:    String?,
                email:              String?,
                firstName:          String?,
                lastName:           String?,
                ownerId:            Int?,
                typeCode:           String?,
                uniqueId:           String?) {
        
        self.cellphoneNumber    = cellphoneNumber
        self.email              = email
        self.firstName          = firstName
        self.lastName           = lastName
        self.ownerId            = ownerId
        self.username           = nil

        self.typeCode           = typeCode
        self.uniqueId           = uniqueId ?? UUID().uuidString
    }
    
    /// Add Contact with username
    public init(email:      String?,
                firstName:  String?,
                lastName:   String?,
                ownerId:    Int?,
                username:   String?,
                typeCode:   String?,
                uniqueId:   String?) {
        
        self.cellphoneNumber    = nil
        self.email              = email
        self.firstName          = firstName
        self.lastName           = lastName
        self.ownerId            = ownerId
        self.username           = username

        self.typeCode           = typeCode
        self.uniqueId           = uniqueId ?? UUID().uuidString
    }
    
}


/// MARK: -  this class will be deprecate.  (use this class instead: 'AddContactRequest')
open class AddContactRequestModel: AddContactRequest {
    
}

