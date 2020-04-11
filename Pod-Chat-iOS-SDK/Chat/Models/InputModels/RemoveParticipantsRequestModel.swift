//
//  RemoveParticipantsRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation

open class RemoveParticipantsRequestModel {
    
    public let participantIds:  [Int]
    public let threadId:        Int
    
    public let typeCode:    String?
    public let uniqueId:    String
    
    public init(participantIds: [Int],
                threadId:       Int,
                typeCode:       String?,
                uniqueId:       String?) {
        
        self.participantIds = participantIds
        self.threadId       = threadId
        
        self.typeCode       = typeCode
        self.uniqueId       = uniqueId ?? UUID().uuidString
    }
    
}

