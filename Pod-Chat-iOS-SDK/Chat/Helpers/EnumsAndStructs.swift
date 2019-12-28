//
//  Helpers.swift
//  Chat
//
//  Created by Mahyar Zhiani on 6/5/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation


enum myNotificationsKeys {
    case GetUserInfo
}

/*
public enum UserEventTypes {
    case userInfo           // type 23
}
*/


//let messageIdsList: [Int] = params["content"].arrayObject! as! [Int]
//var uniqueIdsList: [String] = []
//
//for _ in messageIdsList {
//    let content: JSON = ["content": params["content"].stringValue]
//    var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.FORWARD_MESSAGE.rawValue,
//                                   "pushMsgType": 4,
//                                   "content": content]
//
//    if let threadId = params["subjectId"].int {
//        sendMessageParams["subjectId"] = JSON(threadId)
//    }
//    if let repliedTo = params["repliedTo"].int {
//        sendMessageParams["repliedTo"] = JSON(repliedTo)
//    }
//    if let uniqueId = params["uniqueId"].string {
//        sendMessageParams["uniqueId"] = JSON(uniqueId)
//    }
//    if let metadata = params["metadata"].arrayObject {
//        let metadataStr = "\(metadata)"
//        sendMessageParams["metadata"] = JSON(metadataStr)
//    }
//    sendMessageWithCallback(params: sendMessageParams, callback: nil, sentCallback: SendMessageCallbacks(), deliverCallback: SendMessageCallbacks(), seenCallback: SendMessageCallbacks()) { (theUniqueId) in
//        uniqueIdsList.append(theUniqueId)
//    }
//
//    sendCallbackToUserOnSent = onSent
//    sendCallbackToUserOnDeliver = onDelivere
//    sendCallbackToUserOnSeen = onSeen
//
//}
//
//uniqueIds(uniqueIdsList)






