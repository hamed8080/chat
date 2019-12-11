//
//  GetThreadsCallbacks.swift
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
    
    /*
     * GetThread Response comes from server
     *
     *  save data comes from server to the Cache if needed
     *  send Event to client if needed!
     *  call the "onResultCallback"
     *
     *  + Access:   - private
     *  + Inputs:
     *      - message:      ChatMessage
     *  + Outputs:
     *      - it doesn't have direct output,
     *          but on the situation where the response is valid,
     *          it will call the "onResultCallback" callback to getThreads function (by using "threadsCallbackToUser")
     *
     */
    func responseOfGetThreads(withMessage message: ChatMessage) {
        /*
         *  -> check if we have saves the message uniqueId on the "map" property
         *      -> if yes: (means we send this request and waiting for the response of it)
         *          -> create the "CreateReturnData" variable
         *          -> check if Cache is enabled by the user
         *              -> if yes, save the income Data to the Cache
         *          -> call the "onResultCallback" which will send callback to getThreads function (by using "threadsCallbackToUser")
         *      -> if no: (means this request is maybe is the response of GetAllThreads request)
         *          -> so we have to get the thread Ids, then search on the Cache, and delete threads that are not on the server response.
         *
         */
        log.verbose("Message of type 'GET_THREADS' recieved", context: "Chat")
        
        let returnData = CreateReturnData(hasError:         false,
                                          errorMessage:     "",
                                          errorCode:        0,
                                          result:           nil,
                                          resultAsArray:    message.content?.convertToJSON().array,
                                          resultAsString:   nil,
                                          contentCount:     message.contentCount,
                                          subjectId:        message.subjectId)
        
        if (Chat.map[message.uniqueId] != nil) {
            if (message.uniqueId != "") {
                if enableCache {
                    var conversations = [Conversation]()
                    for item in message.content?.convertToJSON() ?? [:] {
                        let myConversation = Conversation(messageContent: item.1)
                        conversations.append(myConversation)
                    }
                    Chat.cacheDB.saveThread(withThreadObjects: conversations)
                }
                
                let callback: CallbackProtocol = Chat.map[message.uniqueId]!
                callback.onResultCallback(uID:      message.uniqueId,
                                          response: returnData,
                                          success:  { (successJSON) in
                    self.threadsCallbackToUser?(successJSON)
                }) { _ in }
                Chat.map.removeValue(forKey: message.uniqueId)
                
            } else {
                if enableCache {
                    var serverThreadIds: [Int] = []
                    for item in message.content?.convertToJSON() ?? [:] {
                        if let threadId = item.1["id"].int {
                            serverThreadIds.append(threadId)
                        }
                    }
                    var cacheThreadIds: [Int] = []
                    let cacheThreadModel = Chat.cacheDB.retrieveThreads(ascending: false, count: 100000, name: nil, offset: 0, threadIds: nil/*, timeStamp: cacheTimeStamp*/)
                    for thread in cacheThreadModel?.threads ?? [] {
                        if let thID = thread.id {
                            cacheThreadIds.append(thID)
                        }
                    }
                    for sti in serverThreadIds {
                        for (index, cti) in cacheThreadIds.enumerated() {
                            if (sti == cti) {
                                cacheThreadIds.remove(at: index)
                            }
                        }
                    }
                    Chat.cacheDB.deleteThreads(withThreadIds: cacheThreadIds)
                }
            }
        }
    }
    
    public class GetThreadsCallbacks: CallbackProtocol {
        
        var sendParams: SendChatMessageVO
        init(parameters: SendChatMessageVO) {
            self.sendParams = parameters
        }
        
        func onResultCallback(uID:      String,
                              response: CreateReturnData,
                              success:  @escaping callbackTypeAlias,
                              failure:  @escaping callbackTypeAlias) {
            /*
             *  -> check if response hasError or not
             *      -> if no, create the "GetThreadsModel"
             *      -> send the "GetThreadsModel" as a callback
             *
             */
            log.verbose("GetThreadsCallbacks", context: "Chat")
            
            if let arrayContent = response.resultAsArray {
                let content = sendParams.content?.convertToJSON()
                let getThreadsModel = GetThreadsModel(messageContent:   arrayContent,
                                                      contentCount:     response.contentCount,
                                                      count:            content?["count"].intValue ?? 0,
                                                      offset:           content?["offset"].intValue ?? 0,
                                                      hasError:         response.hasError,
                                                      errorMessage:     response.errorMessage,
                                                      errorCode:        response.errorCode)
                success(getThreadsModel)
            }
        }
        
    }
    
}
