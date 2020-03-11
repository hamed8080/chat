//
//  JoinThreadCallbacks.swift
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
    
    func responseOfJoinThread(withMessage message: ChatMessage) {
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
                self.joinThreadCallbackToUser?(successJSON)
            }) { _ in }
            Chat.map.removeValue(forKey: message.uniqueId)
        }
        
    }
    
    public class JoinThreadCallbacks: CallbackProtocol {
        func onResultCallback(uID:      String,
                              response: CreateReturnData,
                              success:  @escaping callbackTypeAlias,
                              failure:  @escaping callbackTypeAlias) {
            log.verbose("BlockContactsCallback", context: "Chat")
            
            if let content = response.result {
                let joinThreadModel = ThreadModel(messageContent:   content,
                                                  hasError:         response.hasError,
                                                  errorMessage:     response.errorMessage,
                                                  errorCode:        response.errorCode)
                success(joinThreadModel)
            }
        }
        
    }
    
}

