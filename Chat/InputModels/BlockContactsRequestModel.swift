//
//  BlockContactsRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation

open class BlockContactsRequestModel {
    
    public let contactId:   Int
    public let typeCode:    String?
    
    public init(contactId: Int, typeCode: String?) {
        self.contactId  = contactId
        self.typeCode   = typeCode
    }
    
}

