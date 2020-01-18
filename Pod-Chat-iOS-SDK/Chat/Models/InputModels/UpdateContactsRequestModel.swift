//
//  UpdateContactsRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation

open class UpdateContactsRequestModel {
    
    public let cellphoneNumber: String
    public let email:           String
    public let firstName:       String
    public let id:              Int
    public let lastName:        String
    
    public let typeCode:        String?
    public let uniqueId:        String
    
    public init(cellphoneNumber:    String,
                email:              String,
                firstName:          String,
                id:                 Int,
                lastName:           String,
                typeCode:           String?,
                uniqueId:           String?) {
        
        self.cellphoneNumber    = cellphoneNumber
        self.email              = email
        self.firstName          = firstName
        self.id                 = id
        self.lastName           = lastName
        self.typeCode           = typeCode
        self.uniqueId           = uniqueId ?? UUID().uuidString
    }
    
}

