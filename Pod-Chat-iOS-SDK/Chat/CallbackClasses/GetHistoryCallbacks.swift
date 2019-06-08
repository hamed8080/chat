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
    
    func chatDelegateGetHistory(getHistory: JSON) {
        let hasError = getHistory["hasError"].boolValue
        let errorMessage = getHistory["errorMessage"].stringValue
        let errorCode = getHistory["errorCode"].intValue
        
        if (!hasError) {
            let result = getHistory["result"]
            let count = result["contentCount"].intValue
            let offset = result["nextOffset"].intValue
            
            let messageContent: [JSON] = getHistory["result"].arrayValue
            let contentCount = getHistory["contentCount"].intValue
            
            //            // save data comes from server to the Cache
            //            var messages = [Message]()
            //            for item in messageContent {
            //                let myMessage = Message(threadId: sendParams["subjectId"].intValue, pushMessageVO: item)
            //                messages.append(myMessage)
            //            }
            //            Chat.cacheDB.saveMessageObjects(messages: messages, getHistoryParams: sendParams)
            
            let getHistoryModel = GetHistoryModel(messageContent: messageContent, contentCount: contentCount, count: count, offset: offset - count, hasError: hasError, errorMessage: errorMessage, errorCode: errorCode, threadId: getHistory["threadId"].int)
            
            delegate?.threadEvents(type: ThreadEventTypes.getHistory, result: getHistoryModel)
        }
    }
    
    public class GetHistoryCallbacks: CallbackProtocol {
        var sendParams: JSON
        init(parameters: JSON) {
            self.sendParams = parameters
        }
        func onResultCallback(uID: String, response: JSON, success: @escaping callbackTypeAlias, failure: @escaping callbackTypeAlias) {
            log.verbose("GetHistoryCallbacks", context: "Chat")
            
            let hasError = response["hasError"].boolValue
            let errorMessage = response["errorMessage"].stringValue
            let errorCode = response["errorCode"].intValue
            
            if (!hasError) {
                let content = sendParams["content"]
                let count = content["count"].intValue
                let offset = content["offset"].intValue
                
                let messageContent: [JSON] = response["result"].arrayValue
                let contentCount = response["contentCount"].intValue
                
                // save data comes from server to the Cache
                var messages = [Message]()
                for item in messageContent {
                    let myMessage = Message(threadId: sendParams["subjectId"].intValue, pushMessageVO: item)
                    messages.append(myMessage)
                }
                Chat.cacheDB.saveMessageObjects(messages: messages, getHistoryParams: sendParams)
                
                let getHistoryModel = GetHistoryModel(messageContent: messageContent,
                                                      contentCount: contentCount,
                                                      count: count,
                                                      offset: offset,
                                                      hasError: hasError,
                                                      errorMessage: errorMessage,
                                                      errorCode: errorCode,
                                                      threadId: response["threadId"].int)
                
                success(getHistoryModel)
            }
        }
    }
    
}
