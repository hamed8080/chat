//
//  CreateThreadCallback.swift
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
    
    /// CreateThread Response comes from server
    ///
    /// - Outputs:
    ///    - it doesn't have direct output,
    ///    - but on the situation where the response is valid,
    ///    - it will call the "onResultCallback" callback to createThread function (by using "createThreadCallbackToUser")
    @available(*,deprecated , message:"Removed in XX.XX.XX version")
    func responseOfCreateThread(withMessage message: ChatMessage) {
        log.verbose("Message of type 'CREATE_THREAD' recieved", context: "Chat")
        
        if let contentAsJSON = message.content?.convertToJSON() {
            let conversationModel = Conversation(messageContent: contentAsJSON)
            let tNewEM = ThreadEventModel(type:         ThreadEventTypes.THREAD_NEW,
                                          participants: nil,
                                          threads:      [conversationModel],
                                          threadId:     message.subjectId,
                                          senderId:     nil,
                                          unreadCount:  message.content?.convertToJSON()["unreadCount"].int,
                                          pinMessage:   nil)
            delegate?.threadEvents(model: tNewEM)
        }
        
        if enableCache {
            if let threadJSON = message.content?.convertToJSON() {
                let myThread = Conversation(messageContent: threadJSON)
                Chat.cacheDB.saveThread(withThreadObjects: [myThread])
            }
        }
        
        let returnData = CreateReturnData(hasError:         false,
                                          errorMessage:     "",
                                          errorCode:        0,
                                          result:           message.content?.convertToJSON(),
                                          resultAsArray:    nil,
                                          resultAsString:   nil,
                                          contentCount:     message.contentCount,
                                          subjectId:        message.subjectId)
        
        if Chat.map[message.uniqueId] != nil {
            let callback: CallbackProtocol = Chat.map[message.uniqueId]!
            callback.onResultCallback(uID: message.uniqueId, response: returnData, success: { (successJSON) in
                self.createThreadCallbackToUser?(successJSON)
            }) { _ in }
            Chat.map.removeValue(forKey: message.uniqueId)
        }
        
    }
    
    @available(*,deprecated , message:"Removed in XX.XX.XX version")
    public class CreateThreadCallback: CallbackProtocol {
        var mySendMessageParams: SendChatMessageVO
        init(parameters: SendChatMessageVO) {
            self.mySendMessageParams = parameters
        }
        
        func onResultCallback(uID:      String,
                              response: CreateReturnData,
                              success:  @escaping callbackTypeAlias,
                              failure:  @escaping callbackTypeAlias) {
            log.verbose("CreateThreadCallback", context: "Chat")
            
            if let content = response.result {
                let createThreadModel = ThreadResponse(messageContent:  content,
                                                       hasError:        response.hasError,
                                                       errorMessage:    response.errorMessage,
                                                       errorCode:       response.errorCode)
                success(createThreadModel)
            }
        }
        
    }
    
}
