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
    
    /// DeleteMessage Response comes from server
    ///
    /// - Outputs:
    ///    - it doesn't have direct output,
    ///    - but on the situation where the response is valid,
    ///    - it will call the "onResultCallback" callback to deleteMessage function (by using "deleteMessageCallbackToUser")
    @available(*,deprecated , message:"Removed in XX.XX.XX version")
    func responseOfDeleteMessage(withMessage message: ChatMessage) {
        log.verbose("Message of type 'DELETE_MESSAGE' recieved", context: "Chat")
        
        let returnData = CreateReturnData(hasError:         false,
                                          errorMessage:     "",
                                          errorCode:        0,
                                          result:           message.content?.convertToJSON(),
                                          resultAsArray:    nil,
                                          resultAsString:   nil,
                                          contentCount:     message.contentCount,
                                          subjectId:        message.subjectId)
        
        if let content = message.content {
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
    
    @available(*,deprecated , message:"Removed in XX.XX.XX version")
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
            
            if let content = response.result {
                let deletedMessageModel = DeleteMessageResponse(messageContent: content,
                                                                hasError:       response.hasError,
                                                                errorMessage:   response.errorMessage,
                                                                errorCode:      response.errorCode)
                
                success(deletedMessageModel)
            }
        }
        
    }
    
}
