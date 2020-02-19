//
//  ChatMessage.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 10/4/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


class ChatMessage {

    var code:           Int?
    let content:        String? // String of JSON
    let contentCount:   Int?
    var message:        String?
    let messageType:    Int
    let subjectId:      Int?
    let time:           Int
    let type:           Int
    let uniqueId:       String
    
    var messageId:      Int? = nil
    var participantId:  Int? = nil
    
    init(code: Int?, content: String?, contentCount: Int?, message: String?, messageType: Int, subjectId: Int?, time: Int, type: Int, uniqueId: String) {
        self.code           = code
        self.content        = content
        self.contentCount   = contentCount
        self.message        = message
        self.messageType    = messageType
        self.subjectId      = subjectId
        self.time           = time
        self.type           = type
        self.uniqueId       = uniqueId
    }
    
    init(withContent: JSON) {
        self.code           = withContent["code"].int
        self.content        = withContent["content"].string
        self.contentCount   = withContent["contentCount"].int
        self.message        = withContent["message"].string
        self.messageType    = withContent["messageType"].intValue
        self.subjectId      = withContent["subjectId"].int
        self.time           = withContent["time"].intValue
        self.type           = withContent["type"].intValue
        self.uniqueId       = withContent["uniqueId"].stringValue
        self.messageId      = withContent["messageId"].int ?? withContent["content"].string?.convertToJSON()["messageId"].int
        self.participantId  = withContent["participantId"].int ?? withContent["content"].string?.convertToJSON()["participantId"].int
    }
    
    func returnToJSON() -> JSON {
        let myReturnValue: JSON = ["code":          code ?? NSNull(),
                                   "content":       content ?? NSNull(),
                                   "contentCount":  contentCount ?? NSNull(),
                                   "message":       message ?? NSNull(),
                                   "messageType":   messageType,
                                   "subjectId":     subjectId ?? NSNull(),
                                   "time":          time,
                                   "type":          type,
                                   "uniqueId":      uniqueId,
                                   "messageId":     messageId ?? NSNull(),
                                   "participantId": participantId ?? NSNull()]
        return myReturnValue
    }
    
}


