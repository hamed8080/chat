//
//  HandleCallStarted.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 9/4/1399 AP.
//  Copyright © 1399 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON
import FanapPodAsyncSDK

extension Chat {
    
    /// CallStarted Response comes from server
    func responseOfCallStarted(withMessage message: ChatMessage) {
        log.verbose("Message of type 'CALL_START' recieved", context: "Chat")
        
        let returnData = CreateReturnData(hasError:         false,
                                          errorMessage:     "",
                                          errorCode:        0,
                                          result:           message.content?.convertToJSON(),
                                          resultAsArray:    nil,
                                          resultAsString:   nil,
                                          contentCount:     message.contentCount,
                                          subjectId:        message.subjectId)
        
        // ToDo: send CallStarted Event
        
        if Chat.map[message.uniqueId] != nil {
            let callback: CallbackProtocol = Chat.map[message.uniqueId]!
            callback.onResultCallback(uID: message.uniqueId, response: returnData, success: { (successJSON) in
                self.callAcceptCallbackToUser?(successJSON)
            }) { _ in }
            Chat.map.removeValue(forKey: message.uniqueId)
        } else if Chat.callMap[message.uniqueId] != nil {
            let callback: CallbackProtocol = Chat.callMap[message.uniqueId]!.first!
            callback.onResultCallback(uID: message.uniqueId, response: returnData, success: { (successJSON) in
                self.callRequestCallbackToUser?(successJSON)
            }) { _ in }
            Chat.callMap[message.uniqueId]?.removeAll()
            Chat.callMap.removeValue(forKey: message.uniqueId)
        }
        
    }
    
}
