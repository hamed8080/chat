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
    
    func chatDelegateGetThread(getThread: JSON) {
        let hasError = getThread["hasError"].boolValue
        let errorMessage = getThread["errorMessage"].stringValue
        let errorCode = getThread["errorCode"].intValue
        
        if (!hasError) {
            let result = getThread["result"]
            let count = result["contentCount"].intValue
            let offset = result["nextOffset"].intValue
            
            let messageContent: [JSON] = getThread["result"].arrayValue
            let contentCount = getThread["contentCount"].intValue
            
            // save data comes from server to the Cache
            var conversations = [Conversation]()
            for item in messageContent {
                let myConversation = Conversation(messageContent: item)
                conversations.append(myConversation)
            }
            Chat.cacheDB.saveThread(withThreadObjects: conversations)
            
            let getThreadsModel = GetThreadsModel(messageContent: messageContent, contentCount: contentCount, count: count, offset: offset - count, hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
            
//            delegate?.threadEvents(type: ThreadEventTypes.getThreads, result: getThreadsModel)
        }
    }
    
    public class GetThreadsCallbacks: CallbackProtocol {
        var sendParams: SendChatMessageVO
        init(parameters: SendChatMessageVO) {
            self.sendParams = parameters
        }
        func onResultCallback(uID: String, response: JSON, success: @escaping callbackTypeAlias, failure: @escaping callbackTypeAlias) {
            log.verbose("GetThreadsCallbacks", context: "Chat")
            
            let hasError = response["hasError"].boolValue
            let errorMessage = response["errorMessage"].stringValue
            let errorCode = response["errorCode"].intValue
            
            if (!hasError) {
//                let content = sendParams["content"]
                let content = sendParams.content.convertToJSON()
                let count = content["count"].intValue
                let offset = content["offset"].intValue
                
                let messageContent: [JSON] = response["result"].arrayValue
                let contentCount = response["contentCount"].intValue
                
                //                // save data comes from server to the Cache
                //                var conversations = [Conversation]()
                //                for item in messageContent {
                //                    let myConversation = Conversation(messageContent: item)
                //                    conversations.append(myConversation)
                //                }
                //                Chat.cacheDB.saveThreadObjects(threads: conversations)
                
                let getThreadsModel = GetThreadsModel(messageContent: messageContent, contentCount: contentCount, count: count, offset: offset, hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
                
                success(getThreadsModel)
            }
        }
        
    }
    
}
