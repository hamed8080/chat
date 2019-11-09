//
//  MuteAndUnmuteThreadRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation

open class MuteAndUnmuteThreadRequestModel {
    
    public let subjectId:       Int
    public let requestTypeCode: String?
    public let requestUniqueId: String?
    
    public init(subjectId:          Int,
                requestTypeCode:    String?,
                requestUniqueId:    String?) {
        
        self.subjectId          = subjectId
        self.requestTypeCode    = requestTypeCode
        self.requestUniqueId    = requestUniqueId
    }
    
}


