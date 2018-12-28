////
////  SendMessage.swift
////  Chat
////
////  Created by Mahyar Zhiani on 6/4/1397 AP.
////  Copyright © 1397 Mahyar Zhiani. All rights reserved.
////
//
//import Foundation
//import SwiftyJSON
//import Async
//
//class SendMessageClass {
//
//    var params: JSON
//    var serverName: String
//    var priority: Int
//    var ttl: Int
//
//    var async: Async
//
//    var token: String
//    var tokenIssuer: String
//
//    var hasResult: Bool
//    var hasSentDeliverSeen: Bool
//
//    init(params: JSON, serverName: String, priority: Int, ttl: Int, async: Async, token: String, tokenIssuer: String, hasResult: Bool, hasSentDeliverSeen: Bool) {
//        self.params = params
//        self.serverName = serverName
//        self.priority = priority
//        self.ttl = ttl
//
//        self.async = async
//
//        self.token = token
//        self.tokenIssuer = tokenIssuer
//
//        self.hasResult = hasResult
//        self.hasSentDeliverSeen = hasSentDeliverSeen
//
////        handleParamsAndSendMessage()
//    }
//
////    var isResult: Bool  = false
////    var isSent: Bool    = false
////    var isDeliver: Bool = false
////    var isSeen: Bool    = false
//
//}
//
//
//class SendMessageClass2 {
//
//    var params:     JSON
//
//    var peerName:   String
//    var priority:   Int
//    var ttl:        Int
//
//    var async: Async
//
//    var token: String
//    var tokenIssuer: String
//
//    init(params: JSON, peerName: String, priority: Int, ttl: Int, async: Async, token: String, tokenIssuer: String) {
//        self.params = params
//        self.peerName = peerName
//        self.priority = priority
//        self.ttl = ttl
//
//        self.async = async
//
//        self.token = token
//        self.tokenIssuer = tokenIssuer
//
//    }
//
//    //    var isResult: Bool  = false
//    //    var isSent: Bool    = false
//    //    var isDeliver: Bool = false
//    //    var isSeen: Bool    = false
//
//
//    func createContent2() {
//
//    }
//
//
//
//}
//
//
//
//
//
//extension SendMessageClass {
//
//    func handleParamsAndSendMessage() {
//        /*
//         * Message to send through async SDK
//         *
//         * + MessageWrapperVO  {object}
//         *    - type           {int}       Type of ASYNC message based on content
//         *    + content        {string}
//         *       -peerName     {string}    Name of receiver Peer
//         *       -receivers[]  {long}      Array of receiver peer ids (if you use this, peerName will be ignored)
//         *       -priority     {int}       Priority of message 1-10, lower has more priority
//         *       -messageId    {long}      Id of message on your side, not required
//         *       -ttl          {long}      Time to live for message in milliseconds
//         *       -content      {string}    Chat Message goes here after stringifying
//         *    - trackId        {long}      Tracker id of message that you receive from DIRANA previously (if you are replying a sync message)
//         */
//
//        var type: Int
//        if let theType = params["pushMsgType"].int {
//            type = theType
//        } else {
//            type = 3
//        }
//
//        let contentStr = messageVOAsStringOfJSON
//
//        let msgSend: JSON = ["peerName": serverName,
//                             "priority": priority,
//                             "content": contentStr,
//                             "ttl": ttl]
//
//        let msgToSendStr: String = "\(msgSend)"
//        async.pushSendData(type: type, content: msgToSendStr)
//
//    }
//
//    func messageVOAsJSON() -> JSON {
//        /*
//         * + ChatMessage        {object}
//         *    - token           {string}
//         *    - tokenIssuer     {string}
//         *    - type            {int}
//         *    - subjectId       {long}
//         *    - uniqueId        {string}
//         *    - content         {string}
//         *    - time            {long}
//         *    - medadata        {string}
//         *    - systemMedadata  {string}
//         *    - repliedTo       {long}
//         */
//        var messageVO: JSON = ["token": token, "tokenIssuer": tokenIssuer]
//
//        let type = params["chatMessageVOTypes"].intValue
//        messageVO.appendIfDictionary(key: "type", json: JSON(type))
//
//        var uniqueId: String
//        if let theUniqueId = params["uniqueId"].string {
//            uniqueId = theUniqueId
//        } else if let uId = params["uniqueId"].array {
//            let uuuIddd = "\(uId)"
//            uniqueId = uuuIddd
//        } else {
//            uniqueId = generateUUID()
//        }
//        messageVO.appendIfDictionary(key: "uniqueId", json: JSON(uniqueId))
//
//
//        if let theSubjectId = params["subjectId"].int {
//            messageVO.appendIfDictionary(key: "threadId", json: JSON(theSubjectId))
//            messageVO.appendIfDictionary(key: "subjectId", json: JSON(theSubjectId))
//        }
//
//        if let theContent = params["content"].string {
//            messageVO.appendIfDictionary(key: "content", json: JSON(theContent))
//        }
//
//        if let theTime = params["time"].string {
//            messageVO.appendIfDictionary(key: "time", json: JSON(theTime))
//        }
//
//        if let theMetaData = params["metadata"].string {
//            messageVO.appendIfDictionary(key: "metadata", json: JSON(theMetaData))
//        }
//
//        if let theSystemMetaData = params["systemMetadata"].string {
//            messageVO.appendIfDictionary(key: "systemMetadata", json: JSON(theSystemMetaData))
//        }
//
//        if let theRepliedTo = params["repliedTo"].int {
//            messageVO.appendIfDictionary(key: "repliedTo", json: JSON(theRepliedTo))
//        }
//
//        return messageVO
//    }
//
//    func messageVOAsStringOfJSON() -> String {
//        let contentJSON = messageVOAsJSON()
//        let contentStr = "\(contentJSON)"
//        return contentStr
//    }
//
//    func generateUUID() -> String {
//
//        return ""
//    }
//
//
//
//}
//
//
//
//
//
//
////// public functions
////extension SendMessageClass {
////
////    public func isMessageSent() -> Bool {
////        return isSent
////    }
////
////    public func isMessageDeliver() -> Bool {
////        return isDeliver
////    }
////
////    public func isMessageSeen() -> Bool {
////        return isSeen
////    }
////}
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
