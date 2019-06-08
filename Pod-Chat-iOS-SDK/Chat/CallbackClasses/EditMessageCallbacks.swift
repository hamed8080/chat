//
//  EditMessageCallbacks.swift
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
    
    public class EditMessageCallbacks: CallbackProtocol {
        var sendParams: JSON
        init(parameters: JSON) {
            self.sendParams = parameters
        }
        func onResultCallback(uID: String, response: JSON, success: @escaping callbackTypeAlias, failure: @escaping callbackTypeAlias) {
            log.verbose("EditMessageCallbacks", context: "Chat")
            
            var returnData: JSON = [:]
            
            let hasError = response["hasError"].boolValue
            let errorMessage = response["errorMessage"].stringValue
            let errorCode = response["errorCode"].intValue
            
            returnData["hasError"] = JSON(hasError)
            returnData["errorMessage"] = JSON(errorMessage)
            returnData["errorCode"] = JSON(errorCode)
            
            if (!hasError) {
                let messageContent: JSON = response["result"]     // send contacts as json to user
                
                // save edited data on the cache
                let message = Message(threadId: sendParams["subjectId"].int, pushMessageVO: messageContent)
                Chat.cacheDB.saveMessageObjects(messages: [message], getHistoryParams: nil)
                
                // the response from server is come correctly, so this message will be removed from wait queue
                if let uID = message.uniqueId {
                    Chat.cacheDB.deleteWaitEditMessage(uniqueId: uID)
                }
                
                let resultData: JSON = ["editedMessage": messageContent]
                
                returnData["result"] = resultData
                success(returnData)
            }
        }
        
    }
    
}
