//
//  UpdateThreadInfoCallback.swift
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
    
    /**
     UpdateThreadInfo Response comes from server
     
     save data comes from server to the Cache if needed
     send Event to client if needed!
     call the "onResultCallback"
        
     + Access:   - private
     + Inputs:
        - message:      ChatMessage
     + Outputs:
        - it doesn't have direct output,
            but on the situation where the response is valid,
            it will call the "onResultCallback" callback to updateThreadInfo function (by using "updateThreadInfoCallbackToUser")
     */
    func responseOfUpdateThreadInfo(withMessage message: ChatMessage) {
        /**
         *
         *  -> send "THREAD_INFO_UPDATED" event to user
         *
         *  -> check if Cache is enabled by the user
         *      -> if yes, save the income Data to the Cache
         *
         *  -> check if we have saves the message uniqueId on the "map" property
         *      -> if yes: (means we send this request and waiting for the response of it)
         *          -> create the "CreateReturnData" variable
         *          -> call the "onResultCallback" which will send callback to getThreads function (by using "threadsCallbackToUser")
         *      -> if no: (means this request is maybe is the response of GetAllThreads request)
         *          -> so we have to get the thread Ids, then search on the Cache, and delete threads that are not on the server response.
         *
         */
        log.verbose("Message of type 'UPDATE_THREAD_INFO' recieved", context: "Chat")
        
//        if let contentAsJSON = message.content?.convertToJSON() {
//            let conversationModel = Conversation(messageContent: contentAsJSON)
//            delegate?.threadEvents(type: ThreadEventTypes.THREAD_INFO_UPDATED, threadId: nil, thread: conversationModel, messageId: nil, senderId: nil)
//        }
        
        let tUpdateInfoEM = ThreadEventModel(type:          ThreadEventTypes.THREAD_INFO_UPDATED,
                                             participants:  nil,
                                             threads:       nil,
                                             threadId:      message.subjectId,
                                             senderId:      nil)
        delegate?.threadEvents(model: tUpdateInfoEM)
        
        
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
                                          contentCount:     nil,
                                          subjectId:        message.subjectId)
        
        if Chat.map[message.uniqueId] != nil {
            let callback: CallbackProtocol = Chat.map[message.uniqueId]!
            callback.onResultCallback(uID:      message.uniqueId,
                                      response: returnData,
                                      success:  { (successJSON) in
                Chat.map.removeValue(forKey: message.uniqueId)
                self.updateThreadInfoCallbackToUser?(successJSON)
            }) { _ in }
            
        }
        
    }
    
    public class UpdateThreadInfoCallback: CallbackProtocol {
        func onResultCallback(uID:      String,
                              response: CreateReturnData,
                              success:  @escaping callbackTypeAlias,
                              failure:  @escaping callbackTypeAlias) {
            /**
             *  -> check if response hasError or not
             *      -> if no, get the data and send a request to get this specific thread with its threadId
             *      -> send the getThreads response to the callback (as "GetThreadsModel")
             */
            log.verbose("UpdateThreadInfoCallback", context: "Chat")
            
            if let content = response.result {
                if let threadId = content["id"].int {
                    let getthreadRequestInput = GetThreadsRequestModel(count:               nil,
                                                                       creatorCoreUserId:   nil,
                                                                       metadataCriteria:    nil,
                                                                       name:                nil,
                                                                       new:                 nil,
                                                                       offset:              nil,
                                                                       partnerCoreContactId: nil,
                                                                       partnerCoreUserId:   nil,
                                                                       threadIds:           [threadId],
                                                                       typeCode:            nil,
                                                                       uniqueId:            uID)
                    Chat.sharedInstance.getThreads(inputModel: getthreadRequestInput, uniqueId: { (_) in }, completion: { (myResponse) in
                        success(myResponse as! GetThreadsModel)
                    }, cacheResponse: { (_) in })
                }
            }
            
        }
        
    }
    
}
