//
//  GetHistoryCallbacks.swift
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
    
    /// GetHistory/GetMentionedList Response comes from server
    ///
    /// - Outputs:
    ///    - it doesn't have direct output,
    ///    - but on the situation where the response is valid,
    ///    - it will call the "onResultCallback" callback to getHistory function (by using "getHistoryCallbackToUser" or "getMentionListCallbackToUser")
    @available(*,deprecated , message:"Removed in 0.10.5.0 version")
    func responseOfGetHistory(withMessage message: ChatMessage) {
        log.verbose("Message of type 'GET_HISTORY' recieved", context: "Chat")
        
        let returnData = CreateReturnData(hasError:         false,
                                          errorMessage:     "",
                                          errorCode:        0,
                                          result:           nil,
                                          resultAsArray:    message.content?.convertToJSON().array,
                                          resultAsString:   nil,
                                          contentCount:     message.contentCount,
                                          subjectId:        message.subjectId)
        
        if Chat.map[message.uniqueId] != nil {
            let callback: CallbackProtocol = Chat.map[message.uniqueId]!
            callback.onResultCallback(uID: message.uniqueId, response: returnData, success: { (successJSON) in
                self.getHistoryCallbackToUser?(successJSON)
            }) { _ in }
            Chat.map.removeValue(forKey: message.uniqueId)
        } else if Chat.mentionMap[message.uniqueId] != nil {
            let callback: CallbackProtocol = Chat.mentionMap[message.uniqueId]!
            callback.onResultCallback(uID: message.uniqueId, response: returnData, success: { (successJSON) in
                self.getMentionListCallbackToUser?(successJSON)
            }) { _ in }
            Chat.mentionMap.removeValue(forKey: message.uniqueId)
        }
    }
    
    @available(*,deprecated , message:"Removed in 0.10.5.0 version")
    public class GetHistoryCallbacks: CallbackProtocol {
        var sendParams: SendChatMessageVO
        init(parameters: SendChatMessageVO) {
            self.sendParams = parameters
        }
        func onResultCallback(uID:      String,
                              response: CreateReturnData,
                              success:  @escaping callbackTypeAlias,
                              failure:  @escaping callbackTypeAlias) {
            log.verbose("GetHistoryCallbacks", context: "Chat")
            
            if let arrayContent = response.resultAsArray as? [JSON] {
                let content = sendParams.content?.convertToJSON()
                
                if Chat.sharedInstance.enableCache {
                    // save data comes from server to the Cache
                    var messages = [Message]()
                    for item in (response.resultAsArray as? [JSON]) ?? [] {
                        let myMessage = Message(threadId: sendParams.subjectId!, pushMessageVO: item)
                        messages.append(myMessage)
                    }
                    
                    handleServerAndCacheDifferential(sendParams: sendParams, serverResponse: messages)
                    Chat.cacheDB.saveMessageObjects(messages: messages, getHistoryParams: sendParams.convertModelToJSON())
                }
                
                let getHistoryModel = GetHistoryResponse(messageContent:    arrayContent,
                                                         contentCount:      response.contentCount,
                                                         count:             content?["count"].intValue ?? 0,
                                                         offset:            content?["offset"].intValue ?? 0,
                                                         hasError:          response.hasError,
                                                         errorMessage:      response.errorMessage,
                                                         errorCode:         response.errorCode,
                                                         threadId:          response.subjectId)
                
                success(getHistoryModel)
            }
        }
        
        
        
        private func handleServerAndCacheDifferential(sendParams: SendChatMessageVO, serverResponse: [Message]) {
            if let content = sendParams.content?.convertToJSON() {
                let getHistoryInput = GetHistoryRequest(json: content)
                if let cacheHistoryResult = Chat.cacheDB.retrieveMessageHistory(count:          getHistoryInput.count ?? 50,
                                                                                firstMessageId: nil,
                                                                                fromTime:       getHistoryInput.fromTime,
                                                                                lastMessageId:  nil,
                                                                                messageId:      getHistoryInput.messageId,
                                                                                messageType:    getHistoryInput.messageType,
                                                                                offset:         getHistoryInput.offset ?? 0,
                                                                                order:          getHistoryInput.order,
                                                                                query:          getHistoryInput.query,
                                                                                threadId:       sendParams.subjectId!,
                                                                                toTime:         getHistoryInput.toTime,
                                                                                uniqueIds:      getHistoryInput.uniqueIds) {
                    
                    // check if there was any message on the server response that wasn't on the cache, send them as New Message Event to the client
                    // check if there was any message on the server response that also was on the cache, then check their data, and if see any difference, send them as Edit Message Event to the client
                    for message in serverResponse {
                        var foundNewMsg = true
                        var foundEditMsg = false
                        for cacheMessage in cacheHistoryResult.history {
                            if (message.id == cacheMessage.id) {
                                foundEditMsg = true
                                foundNewMsg = false
                                if (message.message == cacheMessage.message)
                                    && (message.metadata == cacheMessage.metadata)
                                    && (message.mentioned == cacheMessage.mentioned)
                                    && (message.previousId == cacheMessage.previousId) {
                                    foundEditMsg = false
                                }
                                break
                            }
                        }
                        // meands this message was not on the cache response
                        if foundNewMsg {
                            let messageEventModel = MessageEventModel(type:     MessageEventTypes.MESSAGE_NEW,
                                                                      message:  message,
                                                                      threadId: message.threadId,
                                                                      messageId: nil,
                                                                      senderId: nil,
                                                                      pinned:   content["pinned"].bool)
                            Chat.sharedInstance.delegate?.messageEvents(model: messageEventModel)
                        }
                        
                        // meands this message was not on the cache response
                        if foundEditMsg {
                            let messageEventModel = MessageEventModel(type:     MessageEventTypes.MESSAGE_EDIT,
                                                                      message:  message,
                                                                      threadId: message.threadId,
                                                                      messageId: nil,
                                                                      senderId: nil,
                                                                      pinned:   content["pinned"].bool)
                            Chat.sharedInstance.delegate?.messageEvents(model: messageEventModel)
                        }
                        
                    }
                    
                    // check if there was any message on the cache response that wasn't on the server response, send them as Delete Message Event to the client
                    for cacheMessage in cacheHistoryResult.history {
                        var foundDeleteMsg = false
                        for message in serverResponse {
                            if (cacheMessage.id == message.id) {
                                foundDeleteMsg = true
                                break
                            }
                        }
                        // meands this message was not on the server response
                        if !foundDeleteMsg {
                            let messageEventModel = MessageEventModel(type:     MessageEventTypes.MESSAGE_DELETE,
                                                                      message:  cacheMessage,
                                                                      threadId: cacheMessage.threadId,
                                                                      messageId: nil,
                                                                      senderId: nil,
                                                                      pinned:   content["pinned"].bool)
                            Chat.sharedInstance.delegate?.messageEvents(model: messageEventModel)
                        }
                    }
                    
                }
            }
        }
        
    }
    
    @available(*,deprecated , message:"Removed in 0.10.5.0 version")
    public class GetMentionCallbacks: CallbackProtocol {
        var sendParams: SendChatMessageVO
        init(parameters: SendChatMessageVO) {
            self.sendParams = parameters
        }
        func onResultCallback(uID:      String,
                              response: CreateReturnData,
                              success:  @escaping callbackTypeAlias,
                              failure:  @escaping callbackTypeAlias) {
            log.verbose("GetMentionCallbacks", context: "Chat")
            
            if let arrayContent = response.resultAsArray as? [JSON] {
                let content = sendParams.content?.convertToJSON()
                
                if Chat.sharedInstance.enableCache {
                    
                }
                
                let getHistoryModel = GetHistoryResponse(messageContent:    arrayContent,
                                                         contentCount:      response.contentCount,
                                                         count:             content?["count"].intValue ?? 0,
                                                         offset:            content?["offset"].intValue ?? 0,
                                                         hasError:          response.hasError,
                                                         errorMessage:      response.errorMessage,
                                                         errorCode:         response.errorCode,
                                                         threadId:          response.subjectId)
                
                success(getHistoryModel)
            }
                        
        }
    }
    
    
    
    
    
}
