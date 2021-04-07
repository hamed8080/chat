//
//  SearchContactsRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation

@available(*,deprecated , message:"Removed in XX.XX.XX version.")
open class SearchContactsRequest {
    
    public let cellphoneNumber: String?
    public let contactId:       Int?
    public let count:           Int?
    public let email:           String?
    public let offset:          Int?
    public let order:           Ordering?
    public let query:           String?
    public let summery:         Bool?
    
    public let typeCode:        String?
    public let uniqueId:        String
    
    
    public init(cellphoneNumber:    String?,
                contactId:          Int?,
                count:              Int?,
                email:              String?,
                offset:             Int?,
                order:              Ordering?,
                query:              String?,
                summery:            Bool?,
                typeCode:           String?,
                uniqueId:           String?) {
        
        self.cellphoneNumber    = cellphoneNumber
        self.contactId          = contactId
        self.count              = count
        self.email              = email
        self.offset             = offset
        self.order              = order
        self.query              = query
        self.summery            = summery
        
        self.typeCode           = typeCode
        self.uniqueId           = uniqueId ?? UUID().uuidString
    }
    
}


/// MARK: -  this class will be deprecate (use this class instead: 'SearchContactsRequest')
@available(*,deprecated , message:"Removed in XX.XX.XX version.")
open class SearchContactsRequestModel: SearchContactsRequest {
    
}

