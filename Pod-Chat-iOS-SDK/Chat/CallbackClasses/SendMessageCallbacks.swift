//
//  SendMessageCallbacks.swift
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
    
    public class SendMessageCallbacks: CallbackProtocolWith3Calls {
        var sendParams: SendChatMessageVO
        init(parameters: SendChatMessageVO) {
            self.sendParams = parameters
        }
        func onSent(uID: String, response: JSON, success: @escaping callbackTypeAlias) {
            //
            
            // save this Message on the cache
            // first check if the sendParams threadId is the same as threadId of the Server response, then we will update the cache
            // there is an exeption: when we create thread an send message simultanusly, at first we don't have the threadId, to in this situation we have nothing as threadId in the sendParams, so we get the respose subjectId and save the response on the cache
            if (sendParams.subjectId == response["subjectId"].int) || (sendParams.isCreateThreadAndSendMessage == true) {
                let msg = sendParams.content
                let strWithReturn = msg.replacingOccurrences(of: "Ⓝ", with: "\n")
                let strWithSpace = strWithReturn.replacingOccurrences(of: "Ⓢ", with: " ")
                let messageContent = strWithSpace.replacingOccurrences(of: "Ⓣ", with: "\t")
                
                let message = Message(threadId: response["subjectId"].int, pushMessageVO: response)
                //                let message = Message(threadId:     response["subjectId"].intValue,
                //                                      delivered:    response["delivered"].bool,
                //                                      editable:     response["editable"].bool,
                //                                      edited:       nil,
                //                                      id:           Int(response["content"].stringValue),
                //                                      message:      messageContent,
                //                                      messageType:  response["messageType"].string,
                //                                      metaData:     sendParams["metaData"].string,
                //                                      ownerId:      response["ownerId"].int,
                //                                      previousId:   nil,
                //                                      seen:         response["seen"].bool,
                //                                      time:         response["time"].int,
                //                                      uniqueId:     response["uniqueId"].stringValue,
                //                                      conversation: nil,
                //                                      forwardInfo:  nil,
                //                                      participant:  nil,
                //                                      replyInfo:    nil)
                message.message = messageContent
                message.metaData = sendParams.metaData
                message.id = Int(response["content"].stringValue)
                
                Chat.cacheDB.saveMessageObjects(messages: [message], getHistoryParams: nil)
                
                // the response from server is come correctly, so this message will be removed from wait queue
                if let uID = message.uniqueId {
                    Chat.cacheDB.deleteWaitTextMessage(uniqueId: uID)
                    Chat.cacheDB.deleteWaitFileMessage(uniqueId: uID)
                    Chat.cacheDB.deleteWaitForwardMessage(uniqueId: uID)
                }
            }
            
            success(response)
        }
        
        func onDeliver(uID: String, response: JSON, success: @escaping callbackTypeAlias) {
            //
            success(response)
        }
        
        func onSeen(uID: String, response: JSON, success: @escaping callbackTypeAlias) {
            //
            success(response)
        }
        
    }
    
}
