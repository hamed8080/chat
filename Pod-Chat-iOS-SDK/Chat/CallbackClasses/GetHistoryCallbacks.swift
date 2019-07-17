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
        /*
         *
         *
         *
         */
        log.verbose("Message of type 'GET_HISTORY' recieved", context: "Chat")
        if Chat.map[message.uniqueId] != nil {
            let returnData: JSON = CreateReturnData(hasError:       false,
                                                    errorMessage:   "",
                                                    errorCode:      0,
                                                    result:         message.content?.convertToJSON() ?? [:],
                                                    resultAsString: nil,
                                                    contentCount:   message.contentCount,
                                                    subjectId:      message.subjectId)
                .returnJSON()
            
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
        func onResultCallback(uID: String, response: JSON, success: @escaping callbackTypeAlias, failure: @escaping callbackTypeAlias) {
            log.verbose("GetHistoryCallbacks", context: "Chat")
            
            if (!response["hasError"].boolValue) {
                let content = sendParams.content?.convertToJSON()
                
                // save data comes from server to the Cache
                var messages = [Message]()
                for item in response["result"].arrayValue {
                    let myMessage = Message(threadId: sendParams.subjectId!, pushMessageVO: item)
                    messages.append(myMessage)
                }
                Chat.cacheDB.saveMessageObjects(messages: messages, getHistoryParams: sendParams.convertModelToJSON())
                
                let getHistoryModel = GetHistoryModel(messageContent: response["result"].arrayValue,
                                                      contentCount: response["contentCount"].intValue,
                                                      count:        content?["count"].intValue ?? 0,
                                                      offset:       content?["offset"].intValue ?? 0,
                                                      hasError:     response["hasError"].boolValue,
                                                      errorMessage: response["errorMessage"].stringValue,
                                                      errorCode:    response["errorCode"].intValue,
                                                      threadId:     response["threadId"].int)
                
                success(getHistoryModel)
            }
        }
    }
    
}
