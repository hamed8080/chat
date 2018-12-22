//
//  SearchContactsRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation

open class SearchContactsRequestModel {
    
    public let firstName:       String?
    public let lastName:        String?
    public let cellphoneNumber: String?
    public let email:           String?
    public let id:              Int?
    public let size:            Int?
    public let offset:          Int?
    public let uniqueId:        String?
    //    public let typeCode:        String?
    
    init(firstName:         String?,
         lastName:          String?,
         cellphoneNumber:   String?,
         email:             String?,
         id:                Int?,
         size:              Int?,
         offset:            Int?,
         uniqueId:          String?) {
        
        self.firstName          = firstName
        self.lastName           = lastName
        self.cellphoneNumber    = cellphoneNumber
        self.email              = email
        self.id                 = id
        self.size               = size
        self.offset             = offset
        self.uniqueId           = uniqueId
    }
    
}

