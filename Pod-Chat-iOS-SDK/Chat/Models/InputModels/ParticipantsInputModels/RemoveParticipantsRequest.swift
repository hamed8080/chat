//
//  RemoveParticipantsRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation

@available(*,deprecated , message:"Removed in 0.10.5.0 version.")
open class RemoveParticipantsRequest {
    
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


/// MARK: -  this class will be deprecate (use this class instead: 'RemoveParticipantsRequest')
@available(*,deprecated , message:"Removed in 0.10.5.0 version.")
open class RemoveParticipantsRequestModel: RemoveParticipantsRequest {
    
}

