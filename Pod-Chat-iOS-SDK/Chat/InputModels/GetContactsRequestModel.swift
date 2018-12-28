//
//  GetContactsRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation

open class GetContactsRequestModel {
    
    public let count:       Int?
    public let offset:      Int?
    public let name:        String?
    public let typeCode:    String?
    
    public init(count:     Int?,
                offset:    Int?,
                name:      String?,
                typeCode:  String?) {
        
        self.count      = count
        self.offset     = offset
        self.name       = name
        self.typeCode   = typeCode
    }
    
}

