//
//  UnblockUserCallbacks.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 3/18/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON
import SwiftyBeaver
import FanapPodAsyncSDK


extension Chat {
    
    /*
     * UnblockUser Response comes from server
     *
     *  send Event to client if needed!
     *  call the "onResultCallback"
     *
     *  + Access:   - private
     *  + Inputs:
     *      - message:      ChatMessage
     *  + Outputs:
     *      - it doesn't have direct output,
     *          but on the situation where the response is valid,
     *          it will call the "onResultCallback" callback to unblockContact function (by using "unblockUserCallbackToUser")
     *
     */
    func responseOfUnblockContact(withMessage message: ChatMessage) {
        log.verbose("Message of type 'UNBLOCK' recieved", context: "Chat")
        
        let returnData = CreateReturnData(hasError:         false,
                                          errorMessage:     "",
                                          errorCode:        0,
                                          result:           message.content?.convertToJSON() ?? [:],
                                          resultAsArray:    nil,
                                          resultAsString:   nil,
                                          contentCount:     message.contentCount,
                                          subjectId:        message.subjectId)
        
        if Chat.map[message.uniqueId] != nil {
            let callback: CallbackProtocol = Chat.map[message.uniqueId]!
            callback.onResultCallback(uID:      message.uniqueId,
                                      response: returnData,
                                      success:  { (successJSON) in
                self.unblockUserCallbackToUser?(successJSON)
            }) { _ in }
            Chat.map.removeValue(forKey: message.uniqueId)
        }
        
    }
    
    public class UnblockUserCallbacks: CallbackProtocol {
        func onResultCallback(uID:      String,
                              response: CreateReturnData,
                              success:  @escaping callbackTypeAlias,
                              failure:  @escaping callbackTypeAlias) {
            log.verbose("UnblockContactCallback", context: "Chat")
            
            if let content = response.result {
                let unblockUserModel = BlockedUserModel(messageContent:  content,
                                                        hasError:        response.hasError,
                                                        errorMessage:    response.errorMessage,
                                                        errorCode:       response.errorCode)
                success(unblockUserModel)
            }
        }
    }
    
}
