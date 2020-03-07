//
//  DeleteMessageCallbacks.swift
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
    
    func responseOfDeleteMessage(withMessage message: ChatMessage) {
        log.verbose("Message of type 'DELETE_MESSAGE' recieved", context: "Chat")
        
        let returnData = CreateReturnData(hasError:         false,
                                          errorMessage:     "",
                                          errorCode:        0,
                                          result:           nil,
                                          resultAsArray:    nil,
                                          resultAsString:   message.content,
                                          contentCount:     message.contentCount,
                                          subjectId:        message.subjectId)
        
        if let content = message.content {
//            let myMessage = Message(threadId:       message.subjectId,
//                                    deletable:      nil,
//                                    delivered:      nil,
//                                    editable:       nil,
//                                    edited:         nil,
//                                    id:             Int(content),
//                                    mentioned:      nil,
//                                    message:        nil,
//                                    messageType:    nil,
//                                    metadata:       nil,
//                                    ownerId:        nil,
//                                    pinned:         content.convertToJSON()["pinned"].bool,
//                                    previousId:     nil,
//                                    seen:           nil,
//                                    systemMetadata: nil,
//                                    time:           nil,
//                                    timeNanos:      nil,
//                                    uniqueId:       nil,
//                                    conversation:   nil,
//                                    forwardInfo:    nil,
//                                    participant:    nil,
//                                    replyInfo:      nil)
            
            let messageEventModel = MessageEventModel(type:     MessageEventTypes.MESSAGE_DELETE,
                                                      message:  nil,
                                                      threadId: message.subjectId,
                                                      messageId: message.content?.convertToJSON()["id"].int ?? message.messageId ?? Int(content),
                                                      senderId: nil,
                                                      pinned:   message.content?.convertToJSON()["pinned"].bool)
            delegate?.messageEvents(model: messageEventModel)
            
            if message.content?.convertToJSON()["pinned"].bool ?? false {
                let threadEventModel = ThreadEventModel(type:           ThreadEventTypes.THREAD_LAST_ACTIVITY_TIME,
                                                        participants:   nil,
                                                        threads:        nil,
                                                        threadId:       message.subjectId,
                                                        senderId:       nil,
                                                        unreadCount:    message.content?.convertToJSON()["unreadCount"].int,
                                                        pinMessage:     nil)
                delegate?.threadEvents(model: threadEventModel)
            }
            
        }
        
        if enableCache {
            // ToDo: check in the cache, if this message was pinMessage on the Conversation Model
            // ToDo: check in the cache, if this message was lasMessage on the Conversation Model
            Chat.cacheDB.deleteMessage(inThread: message.subjectId!, allMessages: false, withMessageIds: [Int(message.content ?? "") ?? 0])
        }
        
        if Chat.map[message.uniqueId] != nil {    
            let callback: CallbackProtocol = Chat.map[message.uniqueId]!
            callback.onResultCallback(uID:      message.uniqueId,
                                      response: returnData,
                                      success:  { (successJSON) in
                self.deleteMessageCallbackToUser?(successJSON)
            }) { _ in }
            Chat.map.removeValue(forKey: message.uniqueId)
        }
    }
    
    
    public class DeleteMessageCallbacks: CallbackProtocol {
        var sendParams: SendChatMessageVO
        init(parameters: SendChatMessageVO) {
            self.sendParams = parameters
        }
        func onResultCallback(uID:      String,
                              response: CreateReturnData,
                              success:  @escaping callbackTypeAlias,
                              failure:  @escaping callbackTypeAlias) {
            log.verbose("DeleteMessageCallbacks", context: "Chat")
            
            if let content = response.resultAsString {
                let deletedMessageModel = DeleteMessageModel(deletedMessageId:  Int(content) ?? 0,
                                                             hasError:          response.hasError,
                                                             errorMessage:      response.errorMessage,
                                                             errorCode:         response.errorCode)
                
                success(deletedMessageModel)
            }
        }
        
    }
    
}
