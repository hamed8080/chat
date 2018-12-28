//
//  AddParticipantsRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation

open class AddParticipantsRequestModel {
    
    public let threadId:            Int
    public let contacts:            [Int]
    public let uniqueId:            String?
    public let typeCode:            String?
    
    public init(threadId:  Int,
                contacts:  [Int],
                uniqueId:  String?,
                typeCode:  String?) {
        
        self.threadId           = threadId
        self.contacts           = contacts
        self.uniqueId           = uniqueId
        self.typeCode           = typeCode
    }
    
}

