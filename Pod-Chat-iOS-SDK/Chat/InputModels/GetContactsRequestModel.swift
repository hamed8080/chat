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
    public let name:        String?
    public let offset:      Int?
    public let typeCode:    String?
    
    public init(count:     Int?,
                name:      String?,
                offset:    Int?,
                typeCode:  String?) {
        
        self.count      = count
        self.name       = name
        self.offset     = offset
        self.typeCode   = typeCode
    }
    
}

