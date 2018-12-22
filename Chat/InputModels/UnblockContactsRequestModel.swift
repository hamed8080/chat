//
//  UnblockContactsRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation

open class UnblockContactsRequestModel {
    
    public let blockId:     Int
    public let typeCode:    String?
    
    init(blockId: Int, typeCode: String?) {
        self.blockId    = blockId
        self.typeCode   = typeCode
    }
    
}

