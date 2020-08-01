//
//  UserEventModel.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 5/12/1399 AP.
//  Copyright © 1399 Mahyar Zhiani. All rights reserved.
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
