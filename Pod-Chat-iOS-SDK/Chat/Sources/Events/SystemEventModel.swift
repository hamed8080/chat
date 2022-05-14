//
//  SystemEventModel.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation


open class SystemEventModel {
    
    public let type:       SystemEventTypes
    public let time:       Int?
    public let threadId:   Int?
    public let user:       Any?
    

    init(type: SystemEventTypes, time: Int? = nil, threadId: Int? = nil, user: Any? = nil) {
        self.type       = type
        self.time       = time
        self.threadId   = threadId
        self.user       = user
    }
    
}

public enum SystemEventTypes : Int ,Codable{
    case IS_TYPING      = 1
    case RECORD_VOICE   = 2
    case UPLOAD_PICTURE = 3
    case UPLOAD_VIDEO   = 4
    case UPLOAD_SOUND   = 5
    case UPLOAD_FILE    = 6
    case SERVER_TIME    = -1
}
