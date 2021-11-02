//
//  AsyncMessage.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 10/4/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


class AsyncMessage : Codable {
    
    let content:    String  // String of JSON
    let id:         Int
    let senderId:   Int
    let senderName: String?
    let type:       Int
    let peerName:   String?
    
    init(content: String, id: Int, senderId: Int, senderName: String?, type: Int) {
        self.content    = content
        self.id         = id
        self.senderId   = senderId
        self.senderName = senderName
        self.type       = type
        self.peerName   = nil
    }
    
	@available(*,deprecated , message:"Removed in 0.10.5.0 version")
    init(withContent: JSON) {
        self.content    = withContent["content"].stringValue
        self.id         = withContent["id"].intValue
        self.senderId   = withContent["senderId"].intValue
        self.senderName = withContent["senderName"].string
        self.type       = withContent["type"].intValue
        self.peerName   = withContent["peerName"].string
    }
    
}


