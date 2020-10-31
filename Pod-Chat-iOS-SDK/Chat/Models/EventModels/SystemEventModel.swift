//
//  SystemEventModel.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 10/3/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation


open class SystemEventModel {
    
    public let type:       SystemEventTypes
    public let time:       Int?
    public let threadId:   Int?
    public let user:       Any?
    
    init(type: SystemEventTypes, time: Int?, threadId: Int?, user: Any?) {
        self.type       = type
        self.time       = time
        self.threadId   = threadId
        self.user       = user
    }
    
}



