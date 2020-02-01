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
                    
                    
                    let threadsModel = GetThreadsModel(messageContent: (returnData.resultAsArray as? [JSON]) ?? [],
                                                       contentCount: returnData.contentCount,
                                                       count:        0,
                                                       offset:       0,
                                                       hasError:     false,
                                                       errorMessage: "",
                                                       errorCode:    0)
                    let tLastChangeEM = ThreadEventModel(type:          ThreadEventTypes.THREADS_LIST_CHANGE,
                                                         participants:  nil,
                                                         threads:       threadsModel.threads,
                                                         threadId:      nil,
                                                         senderId:      nil)
                    delegate?.threadEvents(model: tLastChangeEM)
                    
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
//                            let tNewEM = ThreadEventModel(type:          ThreadEventTypes.THREAD_NEW,
//                                                          participants:  nil,
//                                                          threads:       nil,
//                                                          threadId:      thID,
//                                                          senderId:      nil)
//                            delegate?.threadEvents(model: tNewEM)
                        }
                    }
                    for sti in serverThreadIds {
                        for (index, cti) in cacheThreadIds.enumerated() {
                            if (sti == cti) {
                                cacheThreadIds.remove(at: index)
                            }
                        }
                    }
                    
                    for id in cacheThreadIds {
                        let tDeleteEM = ThreadEventModel(type:          ThreadEventTypes.THREAD_DELETE,
                                                         participants:  nil,
                                                         threads:       nil,
                                                         threadId:      id,
                                                         senderId:      nil)
                        delegate?.threadEvents(model: tDeleteEM)
                    }
                    Chat.cacheDB.deleteThreads(withThreadIds: cacheThreadIds)
                    Chat.map.removeValue(forKey: message.uniqueId)
                    
                    
                    
                    print("all file Size = \(getLocalFilesFolderSize())")
                    print("all image Size = \(getLocalImageFolderSize())")
                    print("all folder Size \(getLocalFolderSize())")
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
            log.verbose("GetThreadsCallbacks", context: "Chat")
            
            if let arrayContent = response.resultAsArray as? [JSON] {
                let content = sendParams.content?.convertToJSON()
                
//                if Chat.sharedInstance.enableCache {
//                    // save data comes from server to the Cache
//                    var threads = [Conversation]()
//                    for item in response.resultAsArray ?? [] {
//                        let myThread = Conversation(messageContent: item)
//                        threads.append(myThread)
//                    }
//                    
////                    if (Chat.map[content] != nil) {
////                        if (sendParams.uniqueId != "") {
////
////                        } else {
////
////                        }
////                    }
//                    
//                    handleServerAndCacheDifferential(sendParams: sendParams, serverResponse: threads)
//                    Chat.cacheDB.saveThread(withThreadObjects: threads)
//                }
                
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
        
        
        /*
        private func handleServerAndCacheDifferential(sendParams: SendChatMessageVO, serverResponse: [Conversation]) {
            
            if let content = sendParams.content?.convertToJSON() {
                let getThreadsInput = GetThreadsRequestModel(json: content)
                if let cacheConversationResult = Chat.cacheDB.retrieveThreads(ascending:    true,
                                                                              count:        getThreadsInput.count ?? 50,
                                                                              name:         getThreadsInput.name,
                                                                              offset:       getThreadsInput.offset ?? 0,
                                                                              threadIds:    getThreadsInput.threadIds) {
                    // check if there was any thread on the server response that wasn't on the cache, send them as New Thread Event to the client
                    for thread in serverResponse {
                        var foundThrd = false
                        for cacheThread in cacheConversationResult.threads {
                            if (thread.id == cacheThread.id) {
                                foundThrd = true
                                break
                            }
                        }
                        // meands this contact was not on the cache response
                        if !foundThrd {
                            Chat.sharedInstance.delegate?.threadEvents(type: ThreadEventTypes.THREAD_NEW, threadId: nil, thread: thread, messageId: nil, senderId: nil)
                        }
                    }
                    
                    // check if there was any thread on the cache response that wasn't on the server response, send them as Delete Thread Event to the client
                    for cacheThread in cacheConversationResult.threads {
                        var foundThrd = false
                        for thread in serverResponse {
                            if (cacheThread.id == thread.id) {
                                foundThrd = true
                                break
                            }
                        }
                        // meands this contact was not on the server response
                        if !foundThrd {
                            Chat.sharedInstance.delegate?.threadEvents(type: ThreadEventTypes.THREAD_DELETE, threadId: nil, thread: cacheThread, messageId: nil, senderId: nil)
                        }
                    }
                    
                }
            }
        }
        */
        
    }
    
}
