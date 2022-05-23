//
//  UserEventModel.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation

open class UserEventModel {
    
    public let type:        UserEventTypes
    public let blockModel:  BlockedUser?
    public let threadId:    Int?
    public let roles:[Roles]?
    
    init(type: UserEventTypes, blockModel: BlockedUser? = nil, threadId: Int? = nil, roles:[Roles]? = nil) {
        self.type       = type
        self.blockModel = blockModel
        self.threadId   = threadId
        self.roles      = roles
    }
    
}

public enum UserEventTypes {
    case BLOCK
    case UNBLOCK
    case ROLES
}
