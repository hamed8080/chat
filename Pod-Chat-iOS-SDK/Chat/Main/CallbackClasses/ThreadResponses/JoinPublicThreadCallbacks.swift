//
//  JoinPublicThreadCallbacks.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 12/21/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON
import SwiftyBeaver
import FanapPodAsyncSDK


extension Chat {
    
    /// JoinPublicThread Response comes from server
    ///
    /// - Outputs:
    ///    - it doesn't have direct output,
    ///    - but on the situation where the response is valid,
    ///    - it will call the "onResultCallback" callback to joinPublicThread function (by using "joinPublicThreadCallbackToUser")
    @available(*,deprecated , message:"Removed in 0.10.5.0 version")
    func responseOfJoinPublicThread(withMessage message: ChatMessage) {
        log.verbose("Message of type 'JOIN_THREAD' recieved", context: "Chat")
        
        let returnData = CreateReturnData(hasError:         false,
                                          errorMessage:     "",
                                          errorCode:        0,
                                          result:           message.content?.convertToJSON() ?? [:],
                                          resultAsArray:    nil,
                                          resultAsString:   nil,
                                          contentCount:     message.contentCount,
                                          subjectId:        message.subjectId)
        
        if (Chat.map[message.uniqueId] != nil) {
            let callback: CallbackProtocol = Chat.map[message.uniqueId]!
            callback.onResultCallback(uID:      message.uniqueId,
                                      response: returnData,
                                      success:  { (successJSON) in
                self.joinPublicThreadCallbackToUser?(successJSON)
            }) { _ in }
            Chat.map.removeValue(forKey: message.uniqueId)
        }
        
    }
    
    @available(*,deprecated , message:"Removed in 0.10.5.0 version")
    public class JoinPublicThreadCallbacks: CallbackProtocol {
        func onResultCallback(uID:      String,
                              response: CreateReturnData,
                              success:  @escaping callbackTypeAlias,
                              failure:  @escaping callbackTypeAlias) {
            log.verbose("JoinThreadCallback", context: "Chat")
            
            if let content = response.result {
                let joinThreadModel = ThreadResponse(messageContent:    content,
                                                     hasError:          response.hasError,
                                                     errorMessage:      response.errorMessage,
                                                     errorCode:         response.errorCode)
                success(joinThreadModel)
            }
        }
        
    }
    
}

