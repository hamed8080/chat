//
//  ClearHistoryCallback.swift
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
    
    func responseOfClearHistory(withMessage message: ChatMessage) {
        /*
         *
         *
         *
         */
        log.verbose("Message of type 'CLEAR_HISTORY' recieved", context: "Chat")
        
        let returnData = CreateReturnData(hasError:       false,
                                          errorMessage:   "",
                                          errorCode:      0,
                                          result:         nil,
                                          resultAsArray:  nil,
                                          resultAsString: message.content,
                                          contentCount:   nil,
                                          subjectId:      message.subjectId)
        //                .returnJSON()
        
        if enableCache {
            
        }
        
        if Chat.map[message.uniqueId] != nil {
            let callback: CallbackProtocol = Chat.map[message.uniqueId]!
            callback.onResultCallback(uID:      message.uniqueId,
                                      response: returnData,
                                      success:  { (successJSON) in
                self.clearHistoryCallbackToUser?(successJSON)
            }) { _ in }
            Chat.map.removeValue(forKey: message.uniqueId)
            
        } else if (Chat.spamMap[message.uniqueId] != nil) {
            let callback: CallbackProtocol = Chat.spamMap[message.uniqueId]!.first!
            callback.onResultCallback(uID:      message.uniqueId,
                                      response: returnData,
                                      success:  { (successJSON) in
                                        self.spamPvThreadCallbackToUser?(successJSON)
            }) { _ in }
            Chat.spamMap[message.uniqueId]?.removeFirst()
            if (Chat.spamMap[message.uniqueId]!.count < 1) {
                Chat.spamMap.removeValue(forKey: message.uniqueId)
            }
        }
        
    }
    
    
    public class ClearHistoryCallback: CallbackProtocol {
        var mySendMessageParams: SendChatMessageVO
        init(parameters: SendChatMessageVO) {
            self.mySendMessageParams = parameters
        }
        func onResultCallback(uID:      String,
                              response: CreateReturnData,
                              success:  @escaping callbackTypeAlias,
                              failure:  @escaping callbackTypeAlias) {
            /*
             *
             *
             *
             */
            log.verbose("ClearHistoryCallback", context: "Chat")
            
            if let content = response.resultAsString {
                let clearHistoryModel = ClearHistoryModel(threadId:     Int(content) ?? 0,
                                                          hasError:     response.hasError,
                                                          errorMessage: response.errorMessage,
                                                          errorCode:    response.errorCode)
                
                success(clearHistoryModel)
            }
            
        }
        
    }
    
}
