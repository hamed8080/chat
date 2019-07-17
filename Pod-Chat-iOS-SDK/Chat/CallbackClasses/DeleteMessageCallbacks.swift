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
    
    func responseOfDeleteMessage(withMessage message: ChatMessage) {
        /*
         *
         *
         *
         */
        log.verbose("Message of type 'DELETE_MESSAGE' recieved", context: "Chat")
        if Chat.map[message.uniqueId] != nil {
            let returnData: JSON = CreateReturnData(hasError:       false,
                                                    errorMessage:   "",
                                                    errorCode:      0,
                                                    result:         message.content?.convertToJSON() ?? [:],
                                                    resultAsString: nil,
                                                    contentCount:   message.contentCount,
                                                    subjectId:      message.subjectId)
                .returnJSON()
            
            if enableCache {
                
            }
            
            let callback: CallbackProtocol = Chat.map[message.uniqueId]!
            callback.onResultCallback(uID: message.uniqueId, response: returnData, success: { (successJSON) in
                self.deleteMessageCallbackToUser?(successJSON)
            }) { _ in }
            Chat.map.removeValue(forKey: message.uniqueId)
        }
    }
    
    
    public class DeleteMessageCallbacks: CallbackProtocol {
        var sendParams: SendChatMessageVO
        init(parameters: SendChatMessageVO) {
            self.sendParams = parameters
        }
        func onResultCallback(uID: String, response: JSON, success: @escaping callbackTypeAlias, failure: @escaping callbackTypeAlias) {
            log.verbose("DeleteMessageCallbacks", context: "Chat")
            
            var returnData: JSON = [:]
            
            let hasError = response["hasError"].boolValue
            let errorMessage = response["errorMessage"].stringValue
            let errorCode = response["errorCode"].intValue
            
            returnData["hasError"] = JSON(hasError)
            returnData["errorMessage"] = JSON(errorMessage)
            returnData["errorCode"] = JSON(errorCode)
            
            if (!hasError) {
                let messageContent: String = response["result"].stringValue     // send contacts as json to user
                //                let messageContentJSON: JSON = formatDataFromStringToJSON(stringCont: messageContent).convertStringContentToJSON() // send contacts as object to user
                //                let messageMessageObject = Message(threadId: nil, pushMessageVO: messageContentJSON)
                
                let deletedMessage: JSON = ["id": messageContent]
                let resultData: JSON = ["deletedMessage": deletedMessage]
                
                returnData["result"] = resultData
                
                
//                Chat.cacheDB.deleteMessage(inThread: 1328, withMessageIds: [10799])
                
                success(returnData)
            }
        }
        
    }
    
}
