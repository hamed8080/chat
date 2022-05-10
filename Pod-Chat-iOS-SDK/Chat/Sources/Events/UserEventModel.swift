//
//  UserEventModel.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation

open class UserEventModel {
    
    public let type:        UserEventTypes
    public let blockModel:  BlockedUser
    public let threadId:    Int?
    
    init(type: UserEventTypes, blockModel: BlockedUser, threadId: Int?) {
        self.type       = type
        self.blockModel = blockModel
        self.threadId   = threadId
    }
    
}

public enum UserEventTypes {
    case BLOCK
    case UNBLOCK
}
