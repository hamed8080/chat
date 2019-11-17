//
//  AddContactsRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation

open class AddContactsRequestModel {
    
    public let cellphoneNumber: String?
    public let email:           String?
    public let firstName:       String?
    public let lastName:        String?
    public let requestTypeCode: String?
    public let requestUniqueId: String?
    
    public init(cellphoneNumber:    String?,
                email:              String?,
                firstName:          String?,
                lastName:           String?,
                requestTypeCode:    String?,
                requestUniqueId:    String?) {
        
        self.cellphoneNumber    = cellphoneNumber
        self.email              = email
        self.firstName          = firstName
        self.lastName           = lastName
        self.requestTypeCode    = requestTypeCode
        self.requestUniqueId    = requestUniqueId
    }
    
}

