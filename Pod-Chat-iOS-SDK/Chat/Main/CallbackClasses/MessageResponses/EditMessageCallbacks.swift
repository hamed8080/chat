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
    
    /// EditMessage Response comes from server
    ///
    /// - Outputs:
    ///    - it doesn't have direct output,
    ///    - but on the situation where the response is valid,
    ///    - it will call the "onResultCallback" callback to editMessage function (by using "editMessageCallbackToUser")
    func responseOfEditMessage(withMessage message: ChatMessage) {
        log.verbose("Message of type 'EDIT_MESSAGE' recieved", context: "Chat")
        
        let returnData = CreateReturnData(hasError:         false,
                                          errorMessage:     "",
                                          errorCode:        0,
                                          result:           message.content?.convertToJSON() ?? [:],
                                          resultAsArray:    nil,
                                          resultAsString:   nil,
                                          contentCount:     message.contentCount,
                                          subjectId:        message.subjectId)
        
        let myMessage = Message(threadId:       message.subjectId,
                                pushMessageVO:  message.content?.convertToJSON() ?? [:])
        let messageEventModel = MessageEventModel(type:     MessageEventTypes.MESSAGE_EDIT,
                                                  message:  myMessage,
                                                  threadId: nil,
                                                  messageId: nil,
                                                  senderId: nil,
                                                  pinned:   message.content?.convertToJSON()["pinned"].bool)
        delegate?.messageEvents(model: messageEventModel)
        
        if myMessage.pinned ?? false {
            let threadEventModel = ThreadEventModel(type:           ThreadEventTypes.THREAD_LAST_ACTIVITY_TIME,
                                                    participants:   nil,
                                                    threads:        nil,
                                                    threadId:       message.subjectId,
                                                    senderId:       nil,
                                                    unreadCount:    message.content?.convertToJSON()["unreadCount"].int,
                                                    pinMessage:     nil)
            delegate?.threadEvents(model: threadEventModel)
        }
        
        // save edited data on the cache
        // remove this message from wait edit queue
        if enableCache {
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
//            chatEditMessageHandler(threadId: message.subjectId ?? 0, messageContent: message.content?.convertToJSON() ?? [:])
            Chat.map.removeValue(forKey: message.uniqueId)
        }
    }
    
//    func chatEditMessageHandler(threadId: Int, messageContent: JSON) {
//        let message = Message(threadId: threadId, pushMessageVO: messageContent)
//        delegate?.messageEvents(type: MessageEventTypes.MESSAGE_EDIT, message: message)
//    }
    
    
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
                let editedMessageModel = EditMessageResponse(message:       Message(threadId:       content["conversation"]["id"].int,
                                                                                    pushMessageVO:  response.result!),
                                                             hasError:      response.hasError,
                                                             errorMessage:  response.errorMessage,
                                                             errorCode:     response.errorCode)
                
                success(editedMessageModel)
            }
        }
        
    }
    
}
