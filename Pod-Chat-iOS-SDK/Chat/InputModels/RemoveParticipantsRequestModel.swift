//
//  RemoveParticipantsRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation

open class RemoveParticipantsRequestModel {
    
    public let threadId:            Int
    public let content:             [Int]
    public let uniqueId:            String?
    public let typeCode:            String?
    
    public init(threadId:  Int,
                content:   [Int],
                uniqueId:  String?,
                typeCode:  String?) {
        
        self.threadId           = threadId
        self.content            = content
        self.uniqueId           = uniqueId
        self.typeCode           = typeCode
    }
    
}

