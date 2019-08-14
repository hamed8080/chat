//
//  EditMessageCallbacks.swift
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
    
    func responseOfEditMessage(withMessage message: ChatMessage) {
        /*
         *
         *
         *
         */
        log.verbose("Message of type 'EDIT_MESSAGE' recieved", context: "Chat")
        
        let returnData = CreateReturnData(hasError:         false,
                                          errorMessage:     "",
                                          errorCode:        0,
                                          result:           message.content?.convertToJSON() ?? [:],
                                          resultAsArray:    nil,
                                          resultAsString:   nil,
                                          contentCount:     message.contentCount,
                                          subjectId:        message.subjectId)
        //                .returnJSON()
        
        // save edited data on the cache
        // remove this message from wait edit queue
        if enableCache {
            let myMessage = Message(threadId: message.subjectId, pushMessageVO: message.content?.convertToJSON() ?? [:])
            Chat.cacheDB.saveMessageObjects(messages: [myMessage], getHistoryParams: nil)
            Chat.cacheDB.deleteWaitEditMessage(uniqueId: message.uniqueId)
        }
        
        if Chat.map[message.uniqueId] != nil {
            let callback: CallbackProtocol = Chat.map[message.uniqueId]!
            callback.onResultCallback(uID:      message.uniqueId,
                                      response: returnData,
                                      success: { (successJSON) in
                self.editMessageCallbackToUser?(successJSON)
            }) { _ in }
            chatEditMessageHandler(threadId: message.subjectId ?? 0, messageContent: message.content?.convertToJSON() ?? [:])
            Chat.map.removeValue(forKey: message.uniqueId)
        }
    }
    
    
    public class EditMessageCallbacks: CallbackProtocol {
        var sendParams: SendChatMessageVO
        init(parameters: SendChatMessageVO) {
            self.sendParams = parameters
        }
        func onResultCallback(uID:      String,
                              response: CreateReturnData,
                              success:  @escaping callbackTypeAlias,
                              failure:  @escaping callbackTypeAlias) {
            log.verbose("EditMessageCallbacks", context: "Chat")
            
            if let content = response.result {
                let editedMessageModel = EditMessageModel(message:      Message(threadId: content["conversation"]["id"].int, pushMessageVO: response.result!),
                                                          hasError:     response.hasError,
                                                          errorMessage: response.errorMessage,
                                                          errorCode:    response.errorCode)
                
                success(editedMessageModel)
            }
        }
        
    }
    
}
