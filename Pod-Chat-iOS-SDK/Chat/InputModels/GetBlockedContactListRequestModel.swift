//
//  GetBlockedContactListRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import SwiftyJSON

open class GetBlockedContactListRequestModel {
    
    public let count:           Int?
    public let offset:          Int?
    
    public let requestTypeCode: String?
    public let requestUniqueId: String?
    
    public init(count:              Int?,
                offset:             Int?,
                requestTypeCode:    String?,
                requestUniqueId:    String?) {
        
        self.count              = count
        self.offset             = offset
        self.requestTypeCode    = requestTypeCode
        self.requestUniqueId    = requestUniqueId
    }
    
    func convertContentToJSON() -> JSON {
        var content: JSON = [:]
        content["count"]    = JSON(self.count ?? 50)
        content["offset"]   = JSON(self.offset ?? 0)
        
        return content
    }
    
}

