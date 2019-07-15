//
//  GetBlockedContactListRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation

open class GetBlockedContactListRequestModel {
    
    public let count:       Int?
    public let offset:      Int?
    public let typeCode:    String?
    public let uniqueId:    String?
    
    public init(count:     Int?,
                offset:    Int?,
                typeCode:  String?,
                uniqueId:  String?) {
        
        self.count      = count
        self.offset     = offset
        self.typeCode   = typeCode
        self.uniqueId   = uniqueId
    }
    
}

