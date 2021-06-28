//
//  SendAsyncMessageVO.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 10/4/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

@available(*,deprecated , message:"Removed in 0.10.5.0 version")
class SendAsyncMessageVO {
    
    var content:        String
    let msgTTL:         Int
    let peerName:       String
    let priority:       Int
    let pushMsgType:    Int?
    
    init(content: String, msgTTL: Int, peerName: String, priority: Int, pushMsgType: Int?) {
        self.content        = content
        self.msgTTL         = msgTTL
        self.peerName       = peerName
        self.priority       = priority
        self.pushMsgType    = pushMsgType
    }
    
    init(content: JSON) {
        self.content        = content["content"].stringValue
        self.msgTTL         = content["ttl"].intValue
        self.peerName       = content["peerName"].stringValue
        self.priority       = content["priority"].int ?? 1
        self.pushMsgType    = content["pushMsgType"].intValue
    }
    
    func convertModelToJSON() -> JSON {
        let messageVO: JSON = ["content":   content,
                               "peerName":  peerName,
                               "priority":  priority,
                               "ttl":       msgTTL]
        
        return messageVO
    }
    
    func convertModelToString() -> String {
        if let stringValue = convertModelToJSON().toString() {
            return stringValue
        } else {
            return "\(convertModelToJSON())"
        }
//        let model = convertModelToJSON()
//        let stringModel = "\(model)"
//        let str = String(stringModel.filter { !" \n\t\r".contains($0) })
//        return str
    }
    
    
}


