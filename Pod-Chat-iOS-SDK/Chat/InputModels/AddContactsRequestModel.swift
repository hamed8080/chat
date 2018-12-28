//
//  AddContactsRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation

open class AddContactsRequestModel {
    
    public let firstName:       String?
    public let lastName:        String?
    public let cellphoneNumber: String?
    public let email:           String?
    
    public init(firstName:         String?,
                lastName:          String?,
                cellphoneNumber:   String?,
                email:             String?) {
        
        self.firstName          = firstName
        self.lastName           = lastName
        self.cellphoneNumber    = cellphoneNumber
        self.email              = email
    }
    
}

