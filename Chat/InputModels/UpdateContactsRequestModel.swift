//
//  UpdateContactsRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation

open class UpdateContactsRequestModel {
    
    public let id:              Int
    public let firstName:       String
    public let lastName:        String
    public let cellphoneNumber: String
    public let email:           String
    
    init(id:                Int,
         firstName:         String,
         lastName:          String,
         cellphoneNumber:   String,
         email:             String) {
        
        self.id                 = id
        self.firstName          = firstName
        self.lastName           = lastName
        self.cellphoneNumber    = cellphoneNumber
        self.email              = email
    }
    
}

