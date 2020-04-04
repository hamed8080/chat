//
//  SpamPvThreadRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation

open class SpamPvThreadRequestModel {
    
    public let threadId:    Int?
    
    public let typeCode:    String?
    public let uniqueId:    String
    
    public init(threadId:   Int?,
                typeCode:   String?,
                uniqueId:   String?) {
        
        self.threadId   = threadId
        
        self.typeCode   = typeCode
        self.uniqueId   = uniqueId ?? UUID().uuidString
    }
    
}

