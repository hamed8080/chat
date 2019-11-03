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
    public let requestUniqueId: String?
    
    public init(contactId: Int, requestUniqueId: String?) {
        self.contactId          = contactId
        self.requestUniqueId    = requestUniqueId
    }
    
}

