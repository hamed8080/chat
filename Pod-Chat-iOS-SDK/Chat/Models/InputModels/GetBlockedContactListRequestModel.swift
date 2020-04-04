//
//  GetBlockedContactListRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import SwiftyJSON

open class GetBlockedContactListRequestModel {
    
    public let count:       Int?
    public let offset:      Int?
    
    public let typeCode:    String?
    public let uniqueId:    String
    
    public init(count:      Int?,
                offset:     Int?,
                typeCode:   String?,
                uniqueId:   String?) {
        
        self.count      = count
        self.offset     = offset
        
        self.typeCode   = typeCode
        self.uniqueId   = uniqueId ?? UUID().uuidString
    }
    
    func convertContentToJSON() -> JSON {
        var content: JSON = [:]
        content["count"]    = JSON(self.count ?? 50)
        content["offset"]   = JSON(self.offset ?? 0)
        
        return content
    }
    
}

