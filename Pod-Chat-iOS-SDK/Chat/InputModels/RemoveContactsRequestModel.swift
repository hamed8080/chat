//
//  RemoveContactsRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation

open class RemoveContactsRequestModel {
    
    public let contactId:  Int
    
    public let requestTypeCode: String?
    public let requestUniqueId: String?
    
    public init(contactId:          Int,
                requestTypeCode:    String?,
                requestUniqueId:    String?) {
        
        self.contactId          = contactId
        self.requestTypeCode     = requestTypeCode
        self.requestUniqueId    = requestUniqueId
    }
    
}

