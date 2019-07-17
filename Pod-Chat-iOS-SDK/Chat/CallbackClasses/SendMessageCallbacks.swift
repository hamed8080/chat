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
    
    func responseOfOnSendMessage(withMessage message: ChatMessage) {
        /*
         *  -> check if we have saves the message uniqueId on the "mapOnSent" property
         *  -> if yes: (means we send this request and waiting for the response of it)
         *      -> check if Cache is enabled by the user
         *          -> if yes, save the income Data to the Cache
         *      -> call the "onSent" which will send callback to sendMessage function (by using "sendCallbackToUserOnSent")
         *
         */
        log.verbose("Message of type 'SENT' recieved", context: "Chat")
        if Chat.mapOnSent[message.uniqueId] != nil {
            let returnData: JSON = CreateReturnData(hasError:       false,
                                                    errorMessage:   "",
                                                    errorCode:      0,
                                                    result:         message.content?.convertToJSON() ?? [:],
                                                    resultAsString: nil,
                                                    contentCount:   nil,
                                                    subjectId:      message.content?.convertToJSON()["conversation"]["id"].int)
                .returnJSON()
            
            if enableCache {
                if let msg = message.content?.convertToJSON() {
                    if let tId = msg["conversation"]["id"].int {
                        let theMessage = Message(threadId: tId, pushMessageVO: msg)
                        Chat.cacheDB.saveMessageObjects(messages: [theMessage], getHistoryParams: nil)
                        
                        // the response from server is come correctly, so this message will be removed from wait queue
                        Chat.cacheDB.deleteWaitTextMessage(uniqueId: message.uniqueId)
                        Chat.cacheDB.deleteWaitFileMessage(uniqueId: message.uniqueId)
                        Chat.cacheDB.deleteWaitForwardMessage(uniqueId: message.uniqueId)
                        
                    }
                }
            }
            
            let callback: CallbackProtocolWith3Calls = Chat.mapOnSent[message.uniqueId]!
            callback.onSent(uID:        message.uniqueId,
                            response:   returnData) { (successJSON) in
                self.sendCallbackToUserOnSent?(successJSON)
            }
            Chat.mapOnSent.removeValue(forKey: message.uniqueId)
        }
        
    }
    
    func responseOfOnDeliveredMessage(withMessage message: ChatMessage) {
        /*
         *  -> check if we have saves the message uniqueId on the "mapOnDeliver" property
         *  -> check if we can find the threadId inside the "mapOnDeliver" array
         *      -> yes:
         *          call the "onDeliver", which will send callback to sendMessage function (by using "sendCallbackToUserOnDeliver")
         *      -> no: it means that our request might be CreateThreadWithMessage that we didnt's have threadId befor
         *          call the "onDeliver", which will send callback to creatThreadWithMessage function (by using "sendCallbackToUserOnDeliver")
         *
         *  -> check the messages that are inside the mapOnDeliver threadId, and send mapOnDeliver for all of them that have been send befor this message
         *
         *
         */
        log.verbose("Message of type 'DELIVERY' recieved", context: "Chat")
        
        var findItAt: Int?
        let threadIdObject = Chat.mapOnDeliver["\(message.subjectId ?? 0)"]
        if let threadIdObj = threadIdObject {
            let threadIdObjCount = threadIdObj.count
            if (threadIdObjCount > 0) {
                for i in 1...threadIdObjCount {
                    let uniqueIdObj: [String: CallbackProtocolWith3Calls] = threadIdObj[i - 1]
                    
                    let returnData: JSON = CreateReturnData(hasError:       false,
                                                            errorMessage:   "",
                                                            errorCode:      0,
                                                            result:         message.content?.convertToJSON() ?? [:],
                                                            resultAsString: nil,
                                                            contentCount:   nil,
                                                            subjectId:      message.content?.convertToJSON()["conversation"]["id"].int)
                        .returnJSON()
                    
                    if let callback = uniqueIdObj[message.uniqueId] {
                        findItAt = i
                        callback.onDeliver(uID:         message.uniqueId,
                                           response:    returnData) { (successJSON) in
                            self.sendCallbackToUserOnDeliver?(successJSON)
                        }
                    }
                }
            }
        } else {
            /*
             in situation that Create Thread with send Message, this part will execute,
             because at the beginnig of creating the thread, we don't have the ThreadID
             that we are creating,
             so all messages that sends by creating a thread simultanously, exeute from here:
             */
            let threadIdObject = Chat.mapOnDeliver["\(0)"]
            if let threadIdObj = threadIdObject {
                for (index, item) in threadIdObj.enumerated() {
                    let returnData: JSON = CreateReturnData(hasError:       false,
                                                            errorMessage:   "",
                                                            errorCode:      0,
                                                            result:         message.content?.convertToJSON() ?? [:],
                                                            resultAsString: nil,
                                                            contentCount:   nil,
                                                            subjectId:      message.content?.convertToJSON()["conversation"]["id"].int)
                        .returnJSON()
                    
                    if let callback = item[message.uniqueId] {
                        callback.onDeliver(uID:         message.uniqueId,
                                           response:    returnData) { (successJSON) in
                            self.sendCallbackToUserOnDeliver?(successJSON)
                        }
                        Chat.mapOnDeliver["\(0)"]?.remove(at: index)
                        break
                    }
                }
            }
        }
        
        if let itemAt = findItAt {
            // unique ids that i have to send them that they delivery comes
            var uniqueIdsWithDelivery: [String] = []
            
            // find objects form first to index that delivery comes
            for i in 1...itemAt {
                if let threadIdObj = threadIdObject {
                    let uniqueIdObj = threadIdObj[i - 1]
                    for key in uniqueIdObj.keys {
                        uniqueIdsWithDelivery.append(key)
                    }
                }
            }
            
            // remove items from array and update array
            for i in 0...(itemAt - 1) {
                let index = i
                Chat.mapOnDeliver["\(message.subjectId ?? 0)"]?.remove(at: index)
            }
            
        }
        
    }
    
    func responseOfOnSeenMessage(withMessage message: ChatMessage) {
        /*
         *  -> check if we have saves the message uniqueId on the "mapOnSeen" property
         *  -> check if we can find the threadId inside the "mapOnSeen" array
         *      -> yes:
         *          call the "onSeen", which will send callback to sendMessage function (by using "sendCallbackToUserOnSeen")
         *      -> no: it means that our request might be CreateThreadWithMessage that we didnt's have threadId befor
         *          call the "onSeen", which will send callback to creatThreadWithMessage function (by using "sendCallbackToUserOnSeen")
         *
         *  -> check the messages that are inside the mapOnSeen threadId, and send mapSeen for all of them that have been send befor this message
         *
         *
         */
        log.verbose("Message of type 'SEEN' recieved", context: "Chat")
        
        var findItAt: Int?
        let threadIdObject = Chat.mapOnSeen["\(message.subjectId ?? 0)"]
        if let threadIdObj = threadIdObject {
            if (threadIdObj.count > 0) {
                for i in 1...threadIdObj.count {
                    let index = i - 1
                    let uniqueIdObj: [String: CallbackProtocolWith3Calls] = threadIdObj[index]
                    if let callback = uniqueIdObj[message.uniqueId] {
                        let returnData: JSON = CreateReturnData(hasError:       false,
                                                                errorMessage:   "",
                                                                errorCode:      0,
                                                                result:         message.content?.convertToJSON() ?? [:],
                                                                resultAsString: nil,
                                                                contentCount:   nil,
                                                                subjectId:      message.content?.convertToJSON()["conversation"]["id"].int)
                            .returnJSON()
                        
                        findItAt = i
                        callback.onSeen(uID:        message.uniqueId,
                                        response:   returnData) { (successJSON) in
                            self.sendCallbackToUserOnSeen?(successJSON)
                        }
                    }
                }
            }
        } else {
            /*
             in situation that Create Thread with send Message, this part will execute,
             because at the beginnig of creating the thread, we don't have the ThreadId
             that we are creating,
             so callback of all messages that sends simultanously with creating a thread, exeute from here:
             */
            let threadIdObject = Chat.mapOnSeen["\(0)"]
            if let threadIdObj = threadIdObject {
                for (index, item) in threadIdObj.enumerated() {
                    if let callback = item[message.uniqueId] {
                        let returnData: JSON = CreateReturnData(hasError:       false,
                                                                errorMessage:   "",
                                                                errorCode:      0,
                                                                result:         message.content?.convertToJSON() ?? [:],
                                                                resultAsString: nil,
                                                                contentCount:   nil,
                                                                subjectId:      message.content?.convertToJSON()["conversation"]["id"].int)
                            .returnJSON()
                        
                        callback.onSeen(uID:        message.uniqueId,
                                        response:   returnData) { (successJSON) in
                            self.sendCallbackToUserOnSeen?(successJSON)
                        }
                        Chat.mapOnSeen["\(0)"]?.remove(at: index)
                        break
                    }
                }
            }
        }
        
        if let itemAt = findItAt {
            // unique ids that i have to send them that they delivery comes
            var uniqueIdsWithDelivery: [String] = []
            
            // find objects form first to index that delivery comes
            for i in 1...itemAt {
                if let threadIdObj = threadIdObject {
                    let uniqueIdObj = threadIdObj[i - 1]
                    for key in uniqueIdObj.keys {
                        uniqueIdsWithDelivery.append(key)
                    }
                }
            }
            
            // remove items from array and update array
            for i in 1...itemAt {
                Chat.mapOnSeen["\(message.subjectId ?? 0)"]?.remove(at: i - 1)
            }
        }
        
    }
    
    
    public class SendMessageCallbacks: CallbackProtocolWith3Calls {
        var sendParams: SendChatMessageVO
        init(parameters: SendChatMessageVO) {
            self.sendParams = parameters
        }
        func onSent(uID:        String,
                    response:   JSON,
                    success:    @escaping callbackTypeAlias) {
            /*
             *  -> check if response hasError or not
             *      -> if yes, create the "SendMessageModel"
             *      -> send the "SendMessageModel" as a callback
             *
             */
            log.verbose("SendMessage Sent Callback", context: "Chat")
            if (!response["hasError"].boolValue) {
                let message = SendMessageModel(messageContent:  response["result"],
                                               messageId:       response["result"]["id"].intValue,
                                               isSent:          true,
                                               isDelivered:     false,
                                               isSeen:          false,
                                               hasError:        response["hasError"].boolValue,
                                               errorMessage:    response["errorMessage"].stringValue,
                                               errorCode:       response["errorCode"].intValue,
                                               threadId:        response["result"]["conversation"]["id"].int,
                                               participantId:   response["result"]["participantId"].int)
                success(message)
            }
            
            /*
            // save this Message on the cache
            // first check if the sendParams threadId is the same as threadId of the Server response, then we will update the cache
            // there is an exeption: when we create thread an send message simultanusly, at first we don't have the threadId, to in this situation we have nothing as threadId in the sendParams, so we get the respose subjectId and save the response on the cache
            if (sendParams.subjectId == response["subjectId"].int) || (sendParams.isCreateThreadAndSendMessage == true) {
                let msg = sendParams.content
                let strWithReturn = msg?.replacingOccurrences(of: "Ⓝ", with: "\n")
                let strWithSpace = strWithReturn?.replacingOccurrences(of: "Ⓢ", with: " ")
                let messageContent = strWithSpace?.replacingOccurrences(of: "Ⓣ", with: "\t")
                
                let message = Message(threadId: response["subjectId"].int, pushMessageVO: response)
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
            */
            
        }
        
        func onDeliver(uID:         String,
                       response:    JSON,
                       success:     @escaping callbackTypeAlias) {
            /*
             *  -> check if response hasError or not
             *      -> if yes, create the "SendMessageModel"
             *      -> send the "SendMessageModel" as a callback
             *
             */
            log.verbose("SendMessage Deliver Callback", context: "Chat")
            if (!response["hasError"].boolValue) {
                let message = SendMessageModel(messageContent:  response["result"],
                                               messageId:       response["result"]["id"].intValue,
                                               isSent:          false,
                                               isDelivered:     true,
                                               isSeen:          false,
                                               hasError:        response["hasError"].boolValue,
                                               errorMessage:    response["errorMessage"].stringValue,
                                               errorCode:       response["errorCode"].intValue,
                                               threadId:        response["result"]["threadId"].int,
                                               participantId:   response["result"]["participantId"].int)
                success(message)
            }
            
//            success(response)
        }
        
        func onSeen(uID:        String,
                    response:   JSON,
                    success:    @escaping callbackTypeAlias) {
            /*
             *  -> check if response hasError or not
             *      -> if yes, create the "SendMessageModel"
             *      -> send the "SendMessageModel" as a callback
             *
             */
            log.verbose("SendMessage Seen Callback", context: "Chat")
            if (!response["hasError"].boolValue) {
                let message = SendMessageModel(messageContent:  response["result"],
                                               messageId:       response["result"]["id"].intValue,
                                               isSent:          false,
                                               isDelivered:     false,
                                               isSeen:          true,
                                               hasError:        response["hasError"].boolValue,
                                               errorMessage:    response["errorMessage"].stringValue,
                                               errorCode:       response["errorCode"].intValue,
                                               threadId:        response["result"]["threadId"].int,
                                               participantId:   response["result"]["participantId"].int)
                success(message)
            }
            
//            success(response)
        }
        
    }
    
}
