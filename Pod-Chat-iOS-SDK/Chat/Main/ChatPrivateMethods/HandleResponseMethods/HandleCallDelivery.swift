//
//  HandleCallDelivery.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 9/4/1399 AP.
//  Copyright © 1399 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON
import FanapPodAsyncSDK


extension Chat {
    
    /// CallRejected Response comes from server
    func responseOfCallDelivery(withMessage message: ChatMessage) {
        log.verbose("Message of type 'DELIVER_CALL_REQUEST' recieved", context: "Chat")
        
        var customResult: JSON?
        if let cr = message.content?.convertToJSON() {
            customResult = cr
            customResult!["isDelivered"] = JSON(true)
        }
        
        
        let returnData = CreateReturnData(hasError:         false,
                                          errorMessage:     "",
                                          errorCode:        0,
                                          result:           customResult,
                                          resultAsArray:    nil,
                                          resultAsString:   nil,
                                          contentCount:     message.contentCount,
                                          subjectId:        message.subjectId)
        
        // ToDo: send CallDelivery Event
        
        if Chat.callMap[message.uniqueId] != nil {
            let callback: CallbackProtocol = Chat.callMap[message.uniqueId]!.first!
            callback.onResultCallback(uID: message.uniqueId, response: returnData, success: { (successJSON) in
                self.callRequestCallbackToUser?(successJSON)
            }) { _ in }
            Chat.callMap[message.uniqueId]?.removeFirst()
            if (Chat.callMap[message.uniqueId]!.count < 1) {
                Chat.callMap.removeValue(forKey: message.uniqueId)
            }
        }
        
    }
    
}
