//
//  RemoveContactsRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation

@available(*,deprecated , message:"Removed in XX.XX.XX version.")
open class RemoveContactsRequest {
    
    public let contactId:   Int
    
    public let typeCode:    String?
    public let uniqueId:    String
    
    public init(contactId:  Int,
                typeCode:   String?,
                uniqueId:   String?) {
        
        self.contactId  = contactId
        
        self.typeCode   = typeCode
        self.uniqueId   = uniqueId ?? UUID().uuidString
    }
    
}

/// MARK: -  this class will be deprecate (use this class instead: 'RemoveContactsRequest')
@available(*,deprecated , message:"Removed in XX.XX.XX version.")
open class RemoveContactsRequestModel: RemoveContactsRequest {
    
}

