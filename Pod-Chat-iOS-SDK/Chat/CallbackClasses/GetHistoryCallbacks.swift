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
    
    func responseOfGetHistory(withMessage message: ChatMessage) {
        /**
         *
         */
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
                self.historyCallbackToUser?(successJSON)
            }) { _ in }
            Chat.map.removeValue(forKey: message.uniqueId)
        }
    }
    
    
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
            
            if let arrayContent = response.resultAsArray {
                let content = sendParams.content?.convertToJSON()
                
                if Chat.sharedInstance.enableCache {
                    // save data comes from server to the Cache
                    var messages = [Message]()
                    for item in response.resultAsArray ?? [] {
                        let myMessage = Message(threadId: sendParams.subjectId!, pushMessageVO: item)
                        messages.append(myMessage)
                    }
                    
                    handleServerAndCacheDifferential(sendParams: sendParams, serverResponse: messages)
                    Chat.cacheDB.saveMessageObjects(messages: messages, getHistoryParams: sendParams.convertModelToJSON())
                }
                
                let getHistoryModel = GetHistoryModel(messageContent:   arrayContent,
                                                      contentCount:     response.contentCount,
                                                      count:            content?["count"].intValue ?? 0,
                                                      offset:           content?["offset"].intValue ?? 0,
                                                      hasError:         response.hasError,
                                                      errorMessage:     response.errorMessage,
                                                      errorCode:        response.errorCode,
                                                      threadId:         response.subjectId)
                
                success(getHistoryModel)
            }
        }
        
        
        
        private func handleServerAndCacheDifferential(sendParams: SendChatMessageVO, serverResponse: [Message]) {
            if let content = sendParams.content?.convertToJSON() {
                let getHistoryInput = GetHistoryRequestModel(json: content)
                if let cacheHistoryResult = Chat.cacheDB.retrieveMessageHistory(count:          getHistoryInput.count ?? 50,
                                                                                firstMessageId: nil,
                                                                                fromTime:       getHistoryInput.fromTime,
                                                                                lastMessageId:  nil,
                                                                                messageId:      getHistoryInput.messageId,
                                                                                offset:         getHistoryInput.offset ?? 0,
                                                                                order:          getHistoryInput.order,
                                                                                query:          getHistoryInput.query,
                                                                                threadId:       sendParams.subjectId!,
                                                                                toTime:         getHistoryInput.toTime,
                                                                                uniqueId:       getHistoryInput.uniqueId) {
                    
                    // check if there was any message on the server response that wasn't on the cache, send them as New Message Event to the client
                    for message in serverResponse {
                        var foundMsg = false
                        for cacheMessage in cacheHistoryResult.history {
                            if (message.id == cacheMessage.id) {
                                foundMsg = true
                                break
                            }
                        }
                        // meands this message was not on the cache response
                        if !foundMsg {
                            Chat.sharedInstance.delegate?.messageEvents(type: MessageEventTypes.MESSAGE_NEW, result: message)
                        }
                    }
                    
                    // check if there was any message on the cache response that wasn't on the server response, send them as Delete Message Event to the client
                    for cacheMessage in cacheHistoryResult.history {
                        var foundMsg = false
                        for message in serverResponse {
                            if (cacheMessage.id == message.id) {
                                foundMsg = true
                                break
                            }
                        }
                        // meands this message was not on the server response
                        if !foundMsg {
                            Chat.sharedInstance.delegate?.messageEvents(type: MessageEventTypes.MESSAGE_DELETE, result: cacheMessage)
                        }
                    }
                    
                }
            }
        }
        
        
    }
    
    
    
    
    
    
    
    
}
