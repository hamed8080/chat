//
//  GetContactNotSeenDurationCallback.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 10/30/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation

import Foundation
import SwiftyBeaver
import FanapPodAsyncSDK


extension Chat {
    
    /// GetContactNotSeenDurationt Response comes from server
    ///
    /// - Outputs:
    ///    - it doesn't have direct output,
    ///    - but on the situation where the response is valid,
    ///    - it will call the "onResultCallback" callback to getContactNotSeenDuration function (by using "getContactNotSeenDurationCallbackToUser")
    @available(*,deprecated , message:"Removed in 0.10.5.0 version")
    func responseOfGetContactNotSeenDuration(withMessage message: ChatMessage) {
        log.verbose("Message of type 'GET_NOT_SEEN_DURATION' recieved", context: "Chat")
        
        let returnData = CreateReturnData(hasError:         false,
                                          errorMessage:     "",
                                          errorCode:        0,
                                          result:           message.content?.convertToJSON() ?? [:],
                                          resultAsArray:    nil,
                                          resultAsString:   nil,
                                          contentCount:     nil,
                                          subjectId:        nil)
        
        
        if Chat.map[message.uniqueId] != nil {
            let callback: CallbackProtocol = Chat.map[message.uniqueId]!
            callback.onResultCallback(uID:      message.uniqueId,
                                      response: returnData,
                                      success:  { (successJSON) in
                self.getContactNotSeenDurationCallbackToUser?(successJSON)
            }) { _ in }
            Chat.map.removeValue(forKey: message.uniqueId)
        }
    }
    
    @available(*,deprecated , message:"Removed in 0.10.5.0 version")
    public class GetContactNotSeenDurationCallback: CallbackProtocol {
        func onResultCallback(uID:      String,
                              response: CreateReturnData,
                              success:  @escaping callbackTypeAlias,
                              failure:  @escaping callbackTypeAlias) {
            log.verbose("NotSeenDurationCallback", context: "Chat")
            
            if !(response.hasError) {
                if let content = response.result {
                    let notSeenDurationModel = GetContactNotSeenDurationResponse(notSeenDuration:   content,
                                                                                 hasError:          response.hasError,
                                                                                 errorMessage:      response.errorMessage,
                                                                                 errorCode:         response.errorCode)

                    success(notSeenDurationModel)
                }
            }
            
        }
        
    }
    
}


