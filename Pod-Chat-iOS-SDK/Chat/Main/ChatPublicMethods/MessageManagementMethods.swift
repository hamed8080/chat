//
//  MessageManagementMethods.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 3/21/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import FanapPodAsyncSDK
import SwiftyJSON

// MARK: - Public Methods -
// MARK: - Message Management

extension Chat {
    
    
    // MARK: - Get/Clear History
    
    /*
     GetHistory:
     get messages in a thread
    
     By calling this function, a request of type 15 (GET_HISTORY) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
    
     + Inputs:
     this function will get some optional prameters as an input, as JSON or Model (depends on the function that you would use) which are:
     - threadId:         the Thread that you want to get the history from it.            (Int)
     - count:            how many thread do you want to get with this request.           (Int)       -optional-  , if you don't set it, it would have default value of 50
     - offset:           offset of the contact number that start to count to show.       (Int)       -optional-  , if you don't set it, it would have default value of 0
     - firstMessageId:                       (Int)    -optional-  ,
     - lastMessageId:                        (Int)    -optional-  ,
     - order:            order of showiing the history should be Ascending or descending.    (String)    -optional-  ,
     - query:
     - metadataCriteria:
     - typeCode:
    
     + Outputs:
     It has 2 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- completion:  it will returns the response that comes from server to this request.    (GetHistoryModel)
     3- cacheResponse:  there is another response that comes from CacheDB to the user, if user has set 'enableCache' vaiable to be true
     */
    public func getHistory(getHistoryInput:         GetHistoryRequestModel,
                           uniqueId:                @escaping (String) -> (),
                           completion:              @escaping callbackTypeAlias,
                           cacheResponse:           @escaping (GetHistoryModel) -> (),
                           textMessagesNotSent:     @escaping ([QueueOfWaitTextMessagesModel]) -> (),
                           editMessagesNotSent:     @escaping ([QueueOfWaitEditMessagesModel]) -> (),
                           forwardMessagesNotSent:  @escaping ([QueueOfWaitForwardMessagesModel]) -> (),
                           fileMessagesNotSent:     @escaping ([QueueOfWaitFileMessagesModel]) -> (),
                           uploadImageNotSent:      @escaping ([QueueOfWaitUploadImagesModel]) -> (),
                           uploadFileNotSent:       @escaping ([QueueOfWaitUploadFilesModel]) -> ()) {
        /*
         *
         *
         *
         */
        log.verbose("Try to request to get history with this parameters: \n \(getHistoryInput)", context: "Chat")
        
        historyCallbackToUser = completion
        
        var content: JSON = [:]
        content["count"] = JSON(getHistoryInput.count ?? 50)
        content["offset"] = JSON(getHistoryInput.offset ?? 0)
        if let firstMessageId = getHistoryInput.firstMessageId {
            content["firstMessageId"] = JSON(firstMessageId)
        }
        if let lastMessageId = getHistoryInput.lastMessageId {
            content["lastMessageId"] = JSON(lastMessageId)
        }
        if let from = getHistoryInput.fromTime {
            if let first13Digits = Int(exactly: (from / 1000000)) {
                content["fromTime"] = JSON(first13Digits)
                content["fromTimeNanos"] = JSON(Int(exactly: (from - UInt(first13Digits * 1000000)))!)
            }
        }
        if let to = getHistoryInput.toTime {
            if let first13Digits = Int(exactly: (to / 1000000)) {
                content["toTime"] = JSON(first13Digits)
                content["toTimeNanos"] = JSON(Int(exactly: (to - UInt(first13Digits * 1000000)))!)
            }
        }
        if let order = getHistoryInput.order {
            content["order"] = JSON(order)
        }
        if let query = getHistoryInput.query {
            content["query"] = JSON(query)
        }
        if let metadataCriteria = getHistoryInput.metadataCriteria {
            content["metadataCriteria"] = JSON(metadataCriteria)
        }
//        if let uniqueId = getHistoryInput.uniqueId {
//            content["uniqueId"] = JSON(uniqueId)
//        }
      
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.GET_HISTORY.rawValue,
                                            content:            "\(content)",
                                            metaData:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          getHistoryInput.threadId,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           getHistoryInput.typeCode ?? generalTypeCode,
                                            uniqueId:           nil,
                                            isCreateThreadAndSendMessage: true)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  nil)
     
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callback:           GetHistoryCallbacks(parameters: chatMessage),
                                callbacks:          nil,
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil) { (getHistoryUniqueId) in
            uniqueId(getHistoryUniqueId)
        }
       
        // if cache is enabled by user, first return cache result to the user
        if enableCache {
    
            if let textMessages = Chat.cacheDB.retrieveWaitTextMessages(threadId: getHistoryInput.threadId) {
                textMessagesNotSent(textMessages)
            }
            if let editMessages = Chat.cacheDB.retrieveWaitEditMessages(threadId: getHistoryInput.threadId) {
                editMessagesNotSent(editMessages)
            }
            if let forwardMessages = Chat.cacheDB.retrieveWaitForwardMessages(threadId: getHistoryInput.threadId) {
                forwardMessagesNotSent(forwardMessages)
            }
            if let fileMessages = Chat.cacheDB.retrieveWaitFileMessages(threadId: getHistoryInput.threadId) {
                fileMessagesNotSent(fileMessages)
            }
            if let uploadImages = Chat.cacheDB.retrieveWaitUploadImages(threadId: getHistoryInput.threadId) {
                uploadImageNotSent(uploadImages)
            }
            if let uploadFiles = Chat.cacheDB.retrieveWaitUploadFiles(threadId: getHistoryInput.threadId) {
                uploadFileNotSent(uploadFiles)
            }
           
            if let cacheHistoryResult = Chat.cacheDB.retrieveMessageHistory(count:          getHistoryInput.count ?? 50,
                                                                            firstMessageId: getHistoryInput.firstMessageId,
                                                                            fromTime:       getHistoryInput.fromTime,
                                                                            lastMessageId:  getHistoryInput.lastMessageId,
                                                                            messageId:      0,
                                                                            offset:         getHistoryInput.offset ?? 0,
                                                                            order:          getHistoryInput.order,
                                                                            query:          getHistoryInput.query,
                                                                            threadId:       getHistoryInput.threadId,
                                                                            toTime:         getHistoryInput.toTime,
                                                                            uniqueId:       getHistoryInput.uniqueId) {
                cacheResponse(cacheHistoryResult)
            }
        }
      
    }
   
   
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'GetHistoryRequestModel' to get the parameters, it'll use JSON
    /*
    public func getHistory(params: JSON, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        log.verbose("Try to request to get history with this parameters: \n \(params)", context: "Chat")
       
        var content: JSON = ["count": 50, "offset": 0]
        if let count = params["count"].int {
            if count > 0 {
                content["count"] = JSON(count)
            }
        }
       
        if let offset = params["offset"].int {
            if offset > 0 {
                content["offset"] = JSON(offset)
            }
        }
       
        if let firstMessageId = params["firstMessageId"].int {
            if firstMessageId > 0 {
                content["firstMessageId"] = JSON(firstMessageId)
            }
        }
       
        if let lastMessageId = params["lastMessageId"].int {
            if lastMessageId > 0 {
                content["lastMessageId"] = JSON(lastMessageId)
            }
        }
       
        if let order = params["order"].string {
            content["order"] = JSON(order)
        }
       
        if let query = params["query"].string {
            content["query"] = JSON(query)
        }
       
        if let metadataCriteria = params["metadataCriteria"].string {
            content["metadataCriteria"] = JSON(metadataCriteria)
        } else if (params["metadataCriteria"] != JSON.null) {
            content["metadataCriteria"] = params["metadataCriteria"]
        }
       
        let sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.GET_HISTORY.rawValue,
                                       "content": content,
                                       "typeCode": params["typeCode"].string ?? generalTypeCode,
                                       "subjectId": params["threadId"].intValue]
     
        sendMessageWithCallback(params:         sendMessageParams,
                                callback:       GetHistoryCallbacks(parameters: sendMessageParams),
                                callbacks:      nil,
                                sentCallback:   nil,
                                deliverCallback: nil,
                                seenCallback:   nil) { (getHistoryUniqueId) in
            uniqueId(getHistoryUniqueId)
        }
        historyCallbackToUser = completion
     }
     */
   
   
    /*
     ClearHistory
    
     */
    public func clearHistory(clearHistoryInput: ClearHistoryRequestModel,
                             uniqueId:          @escaping (String) -> (),
                             completion:        @escaping callbackTypeAlias) {
        /*
         *
         *
         *
         */
        log.verbose("Try to request to create clear history with this parameters: \n \(clearHistoryInput)", context: "Chat")
  
        clearHistoryCallbackToUser = completion
    
        var content: JSON = [:]
      
        if let requestUniqueId = clearHistoryInput.uniqueId {
            content["uniqueId"] = JSON(requestUniqueId)
        }
 
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.CLEAR_HISTORY.rawValue,
                                            content:            "\(content)",
                                            metaData:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          clearHistoryInput.threadId,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           nil,
                                            uniqueId:           nil,
                                            isCreateThreadAndSendMessage: true)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  nil)
  
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callback:           ClearHistoryCallback(parameters: chatMessage),
                                callbacks:          nil,
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil) { (clearHistoryUniqueId) in
                                    uniqueId(clearHistoryUniqueId)
        }
    
    }
       
    
    // MARK: - Send/Edit/Reply/Forward Text Message
    /*
     SendTextMessage:
     send a text to somebody.
     
     By calling this function, a request of type 2 (MESSAGE) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some optional prameters as an input, as JSON or Model (depends on the function that you would use) which are:
     - threadId:     id of the thread that you want to remove some participant it.    (Int)
     - content:      array of participants in the thread to remove them.
     - repliedTo:
     - uniqueId:
     - typeCode:
     - systemMetadata:
     - metaData:
     
     + Outputs:
     It has 4 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- onSent:
     3- onDelivere:
     4- onSeen:
     */
    public func sendTextMessage(sendTextMessageInput:   SendTextMessageRequestModel,
                                uniqueId:               @escaping (String) -> (),
                                onSent:                 @escaping callbackTypeAlias,
                                onDelivere:             @escaping callbackTypeAlias,
                                onSeen:                 @escaping callbackTypeAlias) {
        log.verbose("Try to send Message with this parameters: \n \(sendTextMessageInput)", context: "Chat")
        
        let tempUniqueId = generateUUID()
        
        /*
         * seve this message on the Cache Wait Queue,
         * so if there was an situation that response of the server to this message doesn't come,
         * then we know that our message didn't sent correctly
         * and we will send this Queue to user on the GetHistory request,
         * now user knows which messages didn't send correctly, and can handle them
         *
         */
        if enableCache {
            let messageObjectToSendToQueue = QueueOfWaitTextMessagesModel(content:      sendTextMessageInput.content,
                                                                          metaData:     sendTextMessageInput.metaData,
                                                                          repliedTo:    sendTextMessageInput.repliedTo,
                                                                          systemMetadata: sendTextMessageInput.systemMetadata,
                                                                          threadId:     sendTextMessageInput.threadId,
                                                                          typeCode:     sendTextMessageInput.typeCode,
                                                                          uniqueId:     sendTextMessageInput.uniqueId ?? tempUniqueId)
            Chat.cacheDB.saveTextMessageToWaitQueue(textMessage: messageObjectToSendToQueue)
        }
        
        let messageTxtContent = MakeCustomTextToSend(message: sendTextMessageInput.content).replaceSpaceEnterWithSpecificCharecters()
        
        /*
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.MESSAGE.rawValue,
                                       "pushMsgType": 4,
                                       "subjectId": sendTextMessageInput.threadId,
                                       "content": messageTxtContent,
                                       "typeCode": sendTextMessageInput.typeCode ?? generalTypeCode]
        
        if let repliedTo = sendTextMessageInput.repliedTo {
            sendMessageParams["repliedTo"] = JSON(repliedTo)
        }
        
        if let uniqueId = sendTextMessageInput.uniqueId {
            sendMessageParams["uniqueId"] = JSON(uniqueId)
        } else {
            sendMessageParams["uniqueId"] = JSON(tempUniqueId)
        }
        
        if let systemMetadata = sendTextMessageInput.systemMetadata {
            let systemMetadataStr = "\(systemMetadata)"
            sendMessageParams["systemMetadata"] = JSON(systemMetadataStr)
        }
        
        if let metaData = sendTextMessageInput.metaData {
            let metaDataStr = "\(metaData)"
            sendMessageParams["metaData"] = JSON(metaDataStr)
        }
        //        sendMessageParams["subjectId"] = JSON(sendTextMessageInput.threadId)
        */
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.MESSAGE.rawValue,
                                            content:            messageTxtContent,
                                            metaData:           (sendTextMessageInput.metaData != nil) ? "\(sendTextMessageInput.metaData!)" : nil,
                                            repliedTo:          sendTextMessageInput.repliedTo,
                                            systemMetadata:     (sendTextMessageInput.systemMetadata != nil) ? "\(sendTextMessageInput.systemMetadata!)" : nil,
                                            subjectId:          sendTextMessageInput.threadId,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           sendTextMessageInput.typeCode ?? generalTypeCode,
                                            uniqueId:           sendTextMessageInput.uniqueId ?? tempUniqueId,
                                            isCreateThreadAndSendMessage: nil)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  4)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callback:           nil,
                                callbacks:          nil,
                                sentCallback:       SendMessageCallbacks(parameters: chatMessage),
                                deliverCallback:    SendMessageCallbacks(parameters: chatMessage),
                                seenCallback:       SendMessageCallbacks(parameters: chatMessage)) { (theUniqueId) in
            uniqueId(theUniqueId)
        }
        
        sendCallbackToUserOnSent = onSent
        sendCallbackToUserOnDeliver = onDelivere
        sendCallbackToUserOnSeen = onSeen
        
    }
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'SendTextMessageRequestModel' to get the parameters, it'll use JSON
    /*
    public func sendTextMessage(params: JSON, uniqueId: @escaping (String) -> (), onSent: @escaping callbackTypeAlias, onDelivere: @escaping callbackTypeAlias, onSeen: @escaping callbackTypeAlias) {
        log.verbose("Try to send Message with this parameters: \n \(params)", context: "Chat")
        
//        let messageTxtContent = makeCustomTextToSend(textMessage: params["content"].stringValue)
        let messageTxtContent = MakeCustomTextToSend(message: params["content"].stringValue).replaceSpaceEnterWithSpecificCharecters()
        
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.MESSAGE.rawValue,
                                       "pushMsgType": 4,
                                       "typeCode": params["typeCode"].string ?? generalTypeCode,
                                       "content": messageTxtContent]
        
        if let threadId = params["subjectId"].int {
            sendMessageParams["subjectId"] = JSON(threadId)
        }
        if let repliedTo = params["repliedTo"].int {
            sendMessageParams["repliedTo"] = JSON(repliedTo)
        }
        
        if let uniqueId = params["uniqueId"].string {
            sendMessageParams["uniqueId"] = JSON(uniqueId)
        }
        
        if let systemMetadata = params["systemMetadata"].arrayObject {
            sendMessageParams["systemMetadata"] = JSON(systemMetadata)
        }
        
        if let metaData = params["metaData"].arrayObject {
            let metaDataStr = "\(metaData)"
            sendMessageParams["metaData"] = JSON(metaDataStr)
        }
        
        
        sendMessageWithCallback(params:         sendMessageParams,
                                callback:       nil,
                                callbacks:      nil,
                                sentCallback:   SendMessageCallbacks(parameters: sendMessageParams),
                                deliverCallback: SendMessageCallbacks(parameters: sendMessageParams),
                                seenCallback:   SendMessageCallbacks(parameters: sendMessageParams)) { (theUniqueId) in
            uniqueId(theUniqueId)
        }
        
        sendCallbackToUserOnSent = onSent
        sendCallbackToUserOnDeliver = onDelivere
        sendCallbackToUserOnSeen = onSeen
    }
    */
    
    
    
    /*
     EditTextMessage:
     edit text of a messae.
     
     By calling this function, a request of type 28 (EDIT_MESSAGE) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some optional prameters as an input, as JSON or Model (depends on the function that you would use) which are:
     - subjectId:    id of the message that you want to remove some participant it.    (Int)
     - content:      array of participants in the thread to remove them.
     - repliedTo:
     - uniqueId:
     - typeCode:
     - systemMetadata:
     - metaData:
     
     + Outputs:
     It has 4 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- completion:
     */
    public func editMessage(editMessageInput:   EditTextMessageRequestModel,
                            uniqueId:           @escaping (String) -> (),
                            completion:         @escaping callbackTypeAlias) {
        log.verbose("Try to request to edit message with this parameters: \n \(editMessageInput)", context: "Chat")
        let tempUniqueId = generateUUID()
        
        // seve this message on the Cache Wait Queue,
        // so if there was an situation that response of the server to this message doesn't come, then we know that our message didn't sent correctly
        // and we will send this Queue to user on the GetHistory request,
        // now user knows which messages didn't send correctly, and can handle them
        if enableCache {
            let messageObjectToSendToQueue = QueueOfWaitEditMessagesModel(content: editMessageInput.content,
                                                                          metaData: editMessageInput.metaData,
                                                                          repliedTo: editMessageInput.repliedTo,
                                                                          subjectId: editMessageInput.subjectId,
                                                                          typeCode: editMessageInput.typeCode,
                                                                          uniqueId: editMessageInput.uniqueId ?? tempUniqueId)
            Chat.cacheDB.saveEditMessageToWaitQueue(editMessage: messageObjectToSendToQueue)
        }
        
        let messageTxtContent = MakeCustomTextToSend(message: editMessageInput.content).replaceSpaceEnterWithSpecificCharecters()
        
        /*
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.EDIT_MESSAGE.rawValue,
                                       "pushMsgType":       4,
                                       "subjectId":         editMessageInput.subjectId,
                                       "content":           messageTxtContent,
                                       "typeCode":          editMessageInput.typeCode ?? generalTypeCode]
        
        if let repliedTo = editMessageInput.repliedTo {
            sendMessageParams["repliedTo"] = JSON(repliedTo)
        }
        
        if let uniqueId = editMessageInput.uniqueId {
            sendMessageParams["uniqueId"] = JSON(uniqueId)
        } else {
            sendMessageParams["uniqueId"] = JSON(tempUniqueId)
        }
        
        if let metaData = editMessageInput.metaData {
            let metaDataStr = "\(metaData)"
            sendMessageParams["metaData"] = JSON(metaDataStr)
        }
        */
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.EDIT_MESSAGE.rawValue,
                                            content:            messageTxtContent,
                                            metaData:           (editMessageInput.metaData != nil) ? "\(editMessageInput.metaData!)" : nil,
                                            repliedTo:          editMessageInput.repliedTo,
                                            systemMetadata:     nil,
                                            subjectId:          editMessageInput.subjectId,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           editMessageInput.typeCode ?? generalTypeCode,
                                            uniqueId:           editMessageInput.uniqueId ?? tempUniqueId,
                                            isCreateThreadAndSendMessage: nil)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  4)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callback:           EditMessageCallbacks(parameters: chatMessage), callbacks: nil,
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil) { (editMessageUniqueId) in
            uniqueId(editMessageUniqueId)
        }
        editMessageCallbackToUser = completion
        
    }
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'EditTextMessageRequestModel' to get the parameters, it'll use JSON
    /*
    public func editMessage(params: JSON, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        log.verbose("Try to request to edit message with this parameters: \n \(params)", context: "Chat")
        
//        let messageTxtContent = makeCustomTextToSend(textMessage: params["content"].stringValue)
        let messageTxtContent = MakeCustomTextToSend(message: params["content"].stringValue).replaceSpaceEnterWithSpecificCharecters()
        
        let content: JSON = ["content": messageTxtContent]
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.EDIT_MESSAGE.rawValue,
                                       "typeCode": params["typeCode"].string ?? generalTypeCode,
                                       "pushMsgType": 4,
                                       "content": content]
        
        if let threadId = params["subjectId"].int {
            sendMessageParams["subjectId"] = JSON(threadId)
        }
        if let repliedTo = params["repliedTo"].int {
            sendMessageParams["repliedTo"] = JSON(repliedTo)
        }
        if let uniqueId = params["uniqueId"].string {
            sendMessageParams["uniqueId"] = JSON(uniqueId)
        }
        if let metaData = params["metaData"].arrayObject {
            let metaDataStr = "\(metaData)"
            sendMessageParams["metaData"] = JSON(metaDataStr)
        }
        
        sendMessageWithCallback(params:         sendMessageParams,
                                callback:       EditMessageCallbacks(parameters: sendMessageParams),
                                callbacks:      nil,
                                sentCallback:   nil,
                                deliverCallback: nil,
                                seenCallback:   nil) { (editMessageUniqueId) in
            uniqueId(editMessageUniqueId)
        }
        editMessageCallbackToUser = completion
    }
    */
    
    
    
    /*
     ReplyTextMessage:
     send reply message to a messsage.
     
     By calling this function, a request of type 2 (FORWARD_MESSAGE) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some optional prameters as an input, as JSON or Model (depends on the function that you would use) which are:
     - subjectId:    id of the message that you want to remove some participant it.    (Int)
     - content:      array of participants in the thread to remove them.
     - repliedTo:
     - uniqueId:
     - typeCode:
     - systemMetadata:
     - metaData:
     
     + Outputs:
     It has 4 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- onSent:
     3- onDelivere:
     4- onSeen:
     */
    public func replyMessage(replyMessageInput: ReplyTextMessageRequestModel,
                             uniqueId:          @escaping (String) -> (),
                             onSent:            @escaping callbackTypeAlias,
                             onDelivere:        @escaping callbackTypeAlias,
                             onSeen:            @escaping callbackTypeAlias) {
        log.verbose("Try to reply Message with this parameters: \n \(replyMessageInput)", context: "Chat")
        let tempUniqueId = generateUUID()
        
        // seve this message on the Cache Wait Queue,
        // so if there was an situation that response of the server to this message doesn't come, then we know that our message didn't sent correctly
        // and we will send this Queue to user on the GetHistory request,
        // now user knows which messages didn't send correctly, and can handle them
        if enableCache {
            let messageObjectToSendToQueue = QueueOfWaitTextMessagesModel(content:      replyMessageInput.content,
                                                                          metaData:     replyMessageInput.metaData,
                                                                          repliedTo:    replyMessageInput.repliedTo,
                                                                          systemMetadata: nil,
                                                                          threadId:     replyMessageInput.subjectId,
                                                                          typeCode:     replyMessageInput.typeCode,
                                                                          uniqueId:     replyMessageInput.uniqueId ?? tempUniqueId)
            Chat.cacheDB.saveTextMessageToWaitQueue(textMessage: messageObjectToSendToQueue)
        }
        
        let messageTxtContent = MakeCustomTextToSend(message: replyMessageInput.content).replaceSpaceEnterWithSpecificCharecters()
        
        /*
        //        let content: JSON = ["content": messageTxtContent]
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.MESSAGE.rawValue,
                                       "pushMsgType": 4,
                                       "repliedTo": replyMessageInput.repliedTo,
                                       "content": messageTxtContent,
                                       "typeCode": replyMessageInput.typeCode ?? generalTypeCode]
        
        if let uniqueId = replyMessageInput.uniqueId {
            sendMessageParams["uniqueId"] = JSON(uniqueId)
        } else {
            sendMessageParams["uniqueId"] = JSON(tempUniqueId)
        }
        
        if let metaData = replyMessageInput.metaData {
            let metaDataStr = "\(metaData)"
            sendMessageParams["metaData"] = JSON(metaDataStr)
        }
        */
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.MESSAGE.rawValue,
                                            content:            messageTxtContent,
                                            metaData:           (replyMessageInput.metaData != nil) ? "\(replyMessageInput.metaData!)" : nil,
                                            repliedTo:          replyMessageInput.repliedTo,
                                            systemMetadata:     nil,
                                            subjectId:          replyMessageInput.subjectId,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           replyMessageInput.typeCode ?? generalTypeCode,
                                            uniqueId:           replyMessageInput.uniqueId ?? tempUniqueId,
                                            isCreateThreadAndSendMessage: nil)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  4)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callback:           nil,
                                callbacks:          nil,
                                sentCallback:       SendMessageCallbacks(parameters: chatMessage),
                                deliverCallback:    SendMessageCallbacks(parameters: chatMessage),
                                seenCallback:       SendMessageCallbacks(parameters: chatMessage)) { (theUniqueId) in
            uniqueId(theUniqueId)
        }
        
        sendCallbackToUserOnSent = onSent
        sendCallbackToUserOnDeliver = onDelivere
        sendCallbackToUserOnSeen = onSeen
        
    }
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'ReplyTextMessageRequestModel' to get the parameters, it'll use JSON
    /*
    public func replyMessageWith3Callbacks(params: JSON, uniqueId: @escaping (String) -> (), onSent: @escaping callbackTypeAlias, onDelivere: @escaping callbackTypeAlias, onSeen: @escaping callbackTypeAlias) {
        log.verbose("Try to reply Message with this parameters: \n \(params)", context: "Chat")
        
//        let messageTxtContent = makeCustomTextToSend(textMessage: params["content"].stringValue)
        let messageTxtContent = MakeCustomTextToSend(message: params["content"].stringValue).replaceSpaceEnterWithSpecificCharecters()
        
        //        let content: JSON = ["content": messageTxtContent]
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.MESSAGE.rawValue,
                                       "typeCode": params["typeCode"].string ?? generalTypeCode,
                                       "pushMsgType": 4,
                                       "content": messageTxtContent]
        
        if let threadId = params["subjectId"].int {
            sendMessageParams["subjectId"] = JSON(threadId)
        }
        if let repliedTo = params["repliedTo"].int {
            sendMessageParams["repliedTo"] = JSON(repliedTo)
        }
        if let uniqueId = params["uniqueId"].string {
            sendMessageParams["uniqueId"] = JSON(uniqueId)
        }
        if let metaData = params["metaData"].arrayObject {
            let metaDataStr = "\(metaData)"
            sendMessageParams["metaData"] = JSON(metaDataStr)
        }
        
        
        sendMessageWithCallback(params:         sendMessageParams,
                                callback:       nil,
                                callbacks:      nil,
                                sentCallback:   SendMessageCallbacks(parameters: sendMessageParams),
                                deliverCallback: SendMessageCallbacks(parameters: sendMessageParams),
                                seenCallback:   SendMessageCallbacks(parameters: sendMessageParams)) { (theUniqueId) in
            uniqueId(theUniqueId)
        }
        
        sendCallbackToUserOnSent = onSent
        sendCallbackToUserOnDeliver = onDelivere
        sendCallbackToUserOnSeen = onSeen
    }
    */
    
    
    /*
     ForwardTextMessage:
     forwar some messages to a thread.
     
     By calling this function, a request of type 22 (FORWARD_MESSAGE) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some optional prameters as an input, as JSON or Model (depends on the function that you would use) which are:
     - subjectId:       id of the thread that you want to send messages.    (Int)
     - messageIds:      array of message ids to forward them.
     - repliedTo:
     - typeCode:
     - metaData:
     
     + Outputs:
     It has 4 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- onSent:
     3- onDelivere:
     4- onSeen:
     */
    public func forwardMessage(forwardMessageInput: ForwardMessageRequestModel,
                               uniqueIds:           @escaping (String) -> (),
                               onSent:              @escaping callbackTypeAlias,
                               onDelivere:          @escaping callbackTypeAlias,
                               onSeen:              @escaping callbackTypeAlias) {
        log.verbose("Try to Forward with this parameters: \n \(forwardMessageInput)", context: "Chat")
        let tempUniqueId = generateUUID()
        
        // seve this message on the Cache Wait Queue,
        // so if there was an situation that response of the server to this message doesn't come, then we know that our message didn't sent correctly
        // and we will send this Queue to user on the GetHistory request,
        // now user knows which messages didn't send correctly, and can handle them
        if enableCache {
            let messageObjectToSendToQueue = QueueOfWaitForwardMessagesModel(messageIds: forwardMessageInput.messageIds,
                                                                             metaData:  forwardMessageInput.metaData,
                                                                             repliedTo: forwardMessageInput.repliedTo,
                                                                             subjectId: forwardMessageInput.subjectId,
                                                                             typeCode:  forwardMessageInput.typeCode,
                                                                             uniqueId:  tempUniqueId)
            Chat.cacheDB.saveForwardMessageToWaitQueue(forwardMessage: messageObjectToSendToQueue)
        }
        
        let messageIdsList: [Int] = forwardMessageInput.messageIds
        var uniqueIdsList: [String] = []
        
        /*
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.FORWARD_MESSAGE.rawValue,
                                       "pushMsgType": 4,
                                       "content": "\(messageIdsList)",
            "typeCode": forwardMessageInput.typeCode ?? generalTypeCode]
        
        if let repliedTo = forwardMessageInput.repliedTo {
            sendMessageParams["repliedTo"] = JSON(repliedTo)
        }
        
        if let metaData = forwardMessageInput.metaData {
            let metaDataStr = "\(metaData)"
            sendMessageParams["metaData"] = JSON(metaDataStr)
        }
        */
        
        //        let messageIdsListCount = messageIdsList.count
        //        for _ in 0...(messageIdsListCount - 1) {
        for _ in messageIdsList {
            
            let uID = generateUUID()
            uniqueIdsList.append(uID)
            
            let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.FORWARD_MESSAGE.rawValue,
                                                content:            "\(messageIdsList)",
                                                metaData:           (forwardMessageInput.metaData != nil) ? "\(forwardMessageInput.metaData!)" : nil,
                                                repliedTo:          forwardMessageInput.repliedTo,
                                                systemMetadata:     nil,
                                                subjectId:          forwardMessageInput.subjectId,
                                                token:              token,
                                                tokenIssuer:        nil,
                                                typeCode:           forwardMessageInput.typeCode ?? generalTypeCode,
                                                uniqueId:           uID,
                                                isCreateThreadAndSendMessage: nil)
            
            let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                                  msgTTL:       msgTTL,
                                                  peerName:     serverName,
                                                  priority:     msgPriority,
                                                  pushMsgType:  4)
            
            sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                    callback:           nil,
                                    callbacks:          nil,
                                    sentCallback:       SendMessageCallbacks(parameters: chatMessage),
                                    deliverCallback:    SendMessageCallbacks(parameters: chatMessage),
                                    seenCallback:       SendMessageCallbacks(parameters: chatMessage)) { (theUniqueId) in
                uniqueIds(theUniqueId)
            }
            
            sendCallbackToUserOnSent = onSent
            sendCallbackToUserOnDeliver = onDelivere
            sendCallbackToUserOnSeen = onSeen
            
        }
        
    }
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'ForwardMessageRequestModel' to get the parameters, it'll use JSON
    /*
    public func forwardMessageWith3Callbacks(params: JSON, uniqueIds: @escaping (String) -> (), onSent: @escaping callbackTypeAlias, onDelivere: @escaping callbackTypeAlias, onSeen: @escaping callbackTypeAlias) {
        log.verbose("Try to Forward with this parameters: \n \(params)", context: "Chat")
        /*
         subjectId(destination):    Int
         content:                   "[Arr]"
         */
        
        //        let threadId = params["subjectId"].intValue
        let messageIdsList: [Int] = params["content"].arrayObject! as! [Int]
        var uniqueIdsList: [String] = []
        //            let content: JSON = ["content": "\(messageIdsList)"]
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.FORWARD_MESSAGE.rawValue,
                                       "typeCode": params["typeCode"].string ?? generalTypeCode,
                                       "pushMsgType": 4,
                                       "content": "\(messageIdsList)"]
        
        
        if let threadId = params["subjectId"].int {
            sendMessageParams["subjectId"] = JSON(threadId)
        }
        if let repliedTo = params["repliedTo"].int {
            sendMessageParams["repliedTo"] = JSON(repliedTo)
        }
        if let metaData = params["metaData"].arrayObject {
            let metaDataStr = "\(metaData)"
            sendMessageParams["metaData"] = JSON(metaDataStr)
        }
        
        let messageIdsListCount = messageIdsList.count
        for _ in 0...(messageIdsListCount - 1) {
            let uID = generateUUID()
            uniqueIdsList.append(uID)
            
            sendMessageParams["uniqueId"] = JSON("\(uniqueIdsList)")
        }
        
        sendMessageWithCallback(params:         sendMessageParams,
                                callback:       nil,
                                callbacks:      nil,
                                sentCallback:   SendMessageCallbacks(parameters: sendMessageParams),
                                deliverCallback: SendMessageCallbacks(parameters: sendMessageParams),
                                seenCallback:   SendMessageCallbacks(parameters: sendMessageParams)) { (theUniqueId) in
            uniqueIds(theUniqueId)
        }
        
        sendCallbackToUserOnSent = onSent
        sendCallbackToUserOnDeliver = onDelivere
        sendCallbackToUserOnSeen = onSeen
        
        //        for _ in messageIdsList {
        //            let content: JSON = ["content": "\(messageIdsList)"]
        //            var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.FORWARD_MESSAGE.rawValue,
        //                                           "pushMsgType": 4,
        //                                           "content": content]
        //
        //            if let threadId = params["subjectId"].int {
        //                sendMessageParams["subjectId"] = JSON(threadId)
        //            }
        //            if let repliedTo = params["repliedTo"].int {
        //                sendMessageParams["repliedTo"] = JSON(repliedTo)
        //            }
        //            if let uniqueId = params["uniqueId"].string {
        //                sendMessageParams["uniqueId"] = JSON(uniqueId)
        //            }
        //            if let metaData = params["metaData"].arrayObject {
        //                let metaDataStr = "\(metaData)"
        //                sendMessageParams["metaData"] = JSON(metaDataStr)
        //            }
        //            sendMessageWithCallback(params: sendMessageParams, callback: nil, sentCallback: SendMessageCallbacks(), deliverCallback: SendMessageCallbacks(), seenCallback: SendMessageCallbacks()) { (theUniqueId) in
        //                uniqueIdsList.append(theUniqueId)
        //            }
        //
        //            sendCallbackToUserOnSent = onSent
        //            sendCallbackToUserOnDeliver = onDelivere
        //            sendCallbackToUserOnSeen = onSeen
        //        }
        //        uniqueIds(uniqueIdsList)
    }
    */
    
    
    
    // MARK: - Send/Reply File Message
    /*
     SendFileMessage:
     send some file and also send some message too with it.
     
     By calling this function, first an HTTP request of type (GET_IMAGE or GET_FILE), and then send message request of type 2 (MESSAGE) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some optional prameters as an input, as JSON or Model (depends on the function that you would use) which are:
     - fileName:    name of the file (if there was any)
     - imageName:   name of the image (if there was any)
     - xC:
     - yC:
     - hC:
     - wC:
     - threadId:
     - subjectId:
     - repliedTo:
     - content:
     - metaData:
     - typeCode:
     
     + Outputs:
     It has 4 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- uploadProgress:
     3- onSent:
     4- onDelivered:
     5- onSeen:
     */
    public func sendFileMessage(sendFileMessageInput:   SendFileMessageRequestModel,
                                uniqueId:               @escaping (String) -> (),
                                uploadProgress:         @escaping (Float) -> (),
                                onSent:                 @escaping callbackTypeAlias,
                                onDelivered:            @escaping callbackTypeAlias,
                                onSeen:                 @escaping callbackTypeAlias) {
        log.verbose("Try to Send File adn Message with this parameters: \n \(sendFileMessageInput)", context: "Chat")
        
        let messageUniqueId = sendFileMessageInput.uniqueId ?? generateUUID()
        uniqueId(messageUniqueId)
        
        // seve this message on the Cache Wait Queue,
        // so if there was an situation that response of the server to this message doesn't come, then we know that our message didn't sent correctly
        // and we will send this Queue to user on the GetHistory request,
        // now user knows which messages didn't send correctly, and can handle them
        //        let messageObjectToSendToQueue = QueueOfWaitFileMessagesModel(content:      sendFileMessageInput.content,
        //                                                                      fileName:     sendFileMessageInput.fileName,
        //                                                                      imageName:    sendFileMessageInput.imageName,
        //                                                                      metaData:     sendFileMessageInput.metaData,
        //                                                                      repliedTo:    sendFileMessageInput.repliedTo,
        //                                                                      subjectId:    sendFileMessageInput.subjectId,
        //                                                                      threadId:     sendFileMessageInput.threadId,
        //                                                                      typeCode:     sendFileMessageInput.typeCode,
        //                                                                      uniqueId:     messageUniqueId,
        //                                                                      xC:           sendFileMessageInput.xC,
        //                                                                      yC:           sendFileMessageInput.yC,
        //                                                                      hC:           sendFileMessageInput.hC,
        //                                                                      wC:           sendFileMessageInput.wC,
        //                                                                      fileToSend:   sendFileMessageInput.fileToSend,
        //                                                                      imageToSend:  sendFileMessageInput.imageToSend)
        // this line couses an error!!
        //        Chat.cacheDB.saveFileMessageToWaitQueue(fileMessage: messageObjectToSendToQueue)
        if enableCache {
            let messageObjectToSendToQueue = QueueOfWaitFileMessagesModel(content:      sendFileMessageInput.content,
                                                                          fileName:     sendFileMessageInput.fileName,
                                                                          imageName:    sendFileMessageInput.imageName,
                                                                          metaData:     sendFileMessageInput.metaData,
                                                                          repliedTo:    sendFileMessageInput.repliedTo,
                                                                          threadId:     sendFileMessageInput.threadId,
                                                                          typeCode:     sendFileMessageInput.typeCode,
                                                                          uniqueId:     messageUniqueId,
                                                                          xC:           sendFileMessageInput.xC,
                                                                          yC:           sendFileMessageInput.yC,
                                                                          hC:           sendFileMessageInput.hC,
                                                                          wC:           sendFileMessageInput.wC,
                                                                          fileToSend:   sendFileMessageInput.fileToSend,
                                                                          imageToSend:  sendFileMessageInput.imageToSend)
            Chat.cacheDB.saveFileMessageToWaitQueue(fileMessage: messageObjectToSendToQueue)
        }
        
        
//        var fileName:       String  = sendFileMessageInput.fileName ?? sendFileMessageInput.imageName ?? ""
//        var fileType:       String  = ""
        var fileSize:       Int     = 0
        var fileExtension:  String  = ""
        
//        if let myFileName = sendFileMessageInput.fileName {
//            fileName = myFileName
//        } else if let myImageName = sendFileMessageInput.imageName {
//            fileName = myImageName
//        }
        
        let uploadUniqueId = generateUUID()
        
        var metaData: JSON = [:]
        metaData["file"]["originalName"] = JSON(sendFileMessageInput.fileName ?? sendFileMessageInput.imageName ?? "")
        metaData["file"]["mimeType"]    = JSON("")
        metaData["file"]["size"]        = JSON(fileSize)
        
//        var paramsToSendToUpload: JSON = ["uniqueId": uploadUniqueId, "originalFileName": fileName]
//        if let xC = sendFileMessageInput.xC {
//            paramsToSendToUpload["xC"] = JSON(xC)
//        }
//        if let yC = sendFileMessageInput.yC {
//            paramsToSendToUpload["yC"] = JSON(yC)
//        }
//        if let hC = sendFileMessageInput.hC {
//            paramsToSendToUpload["hC"] = JSON(hC)
//        }
//        if let wC = sendFileMessageInput.wC {
//            paramsToSendToUpload["wC"] = JSON(wC)
//        }
//        if let fileName = sendFileMessageInput.fileName {
//            paramsToSendToUpload["fileName"] = JSON(fileName)
//        } else {
//            paramsToSendToUpload["fileName"] = JSON(uploadUniqueId)
//        }
        //        if let threadId = sendFileMessageInput.threadId {
        //            paramsToSendToUpload["threadId"] = JSON(threadId)
        //        }
//        var paramsToSendToSendMessage: JSON = ["uniqueId": messageUniqueId,
//                                               "typeCode": sendFileMessageInput.typeCode ?? generalTypeCode]
        //        if let subjectId = sendFileMessageInput.subjectId {
        //            paramsToSendToSendMessage["subjectId"] = JSON(subjectId)
        //            paramsToSendToSendMessage["threadId"] = JSON(subjectId)
        //        }
//        if let threadId = sendFileMessageInput.threadId {
//            paramsToSendToSendMessage["subjectId"] = JSON(threadId)
//            paramsToSendToSendMessage["threadId"] = JSON(threadId)
//        }
//        if let repliedTo = sendFileMessageInput.repliedTo {
//            paramsToSendToSendMessage["repliedTo"] = JSON(repliedTo)
//        }
//        if let content = sendFileMessageInput.content {
//            paramsToSendToSendMessage["content"] = JSON("\(content)")
//        }
//        if let systemMetadata = sendFileMessageInput.metaData {
//            paramsToSendToSendMessage["systemMetadata"] = JSON("\(systemMetadata)")
//        }
        
        
        if let image = sendFileMessageInput.imageToSend {
            let uploadRequest = UploadImageRequestModel(dataToSend:         image,
                                                        fileExtension:      fileExtension,
                                                        fileName:           sendFileMessageInput.imageName ?? "defaultName",
                                                        fileSize:           fileSize,
                                                        originalFileName:   sendFileMessageInput.fileName ?? uploadUniqueId,
                                                        threadId:           sendFileMessageInput.threadId,
                                                        uniqueId:           uploadUniqueId,
                                                        xC:                 Int(sendFileMessageInput.xC ?? ""),
                                                        yC:                 Int(sendFileMessageInput.yC ?? ""),
                                                        hC:                 Int(sendFileMessageInput.hC ?? ""),
                                                        wC:                 Int(sendFileMessageInput.wC ?? ""))
            uploadImage(uploadImageInput: uploadRequest,
                        uniqueId: { _ in },
                        progress: { (progress) in
                            uploadProgress(progress)
            }) { (response) in
                let myResponse: UploadImageModel = response as! UploadImageModel
                let link = "\(self.SERVICE_ADDRESSES.FILESERVER_ADDRESS)\(SERVICES_PATH.GET_IMAGE.rawValue)?imageId=\(myResponse.uploadImage!.id ?? 0)&hashCode=\(myResponse.uploadImage!.hashCode ?? "")"
                
                var fileJSON : JSON = [:]
                
                fileJSON["link"]            = JSON(link)
                fileJSON["id"]              = JSON(myResponse.uploadImage!.id ?? 0)
                fileJSON["name"]            = JSON(myResponse.uploadImage!.name ?? "")
                fileJSON["height"]          = JSON(myResponse.uploadImage!.height ?? 0)
                fileJSON["width"]           = JSON(myResponse.uploadImage!.width ?? 0)
                fileJSON["actualHeight"]    = JSON(myResponse.uploadImage!.actualHeight ?? 0)
                fileJSON["actualWidth"]     = JSON(myResponse.uploadImage!.actualWidth ?? 0)
                fileJSON["hashCode"]        = JSON(myResponse.uploadImage!.hashCode ?? "")
                
                metaData["file"] = fileJSON
//                paramsToSendToSendMessage["metaData"] = JSON("\(metaData)")
//                sendMessageWith(paramsToSendToSendMessage: paramsToSendToSendMessage)
                
                sendMessageWith(withMetaData: metaData)
            }
            
            
//            uploadImage(params:     paramsToSendToUpload,
//                        dataToSend: image,
//                        uniqueId:   { _ in },
//                        progress:   { (progress) in
//                uploadProgress(progress)
//            }) { (response) in
//                let myResponse: UploadImageModel = response as! UploadImageModel
//                let link = "\(self.SERVICE_ADDRESSES.FILESERVER_ADDRESS)\(SERVICES_PATH.GET_IMAGE.rawValue)?imageId=\(myResponse.uploadImage!.id ?? 0)&hashCode=\(myResponse.uploadImage!.hashCode ?? "")"
//
//                var fileJSON : JSON = [:]
//
//                fileJSON["link"]            = JSON(link)
//                fileJSON["id"]              = JSON(myResponse.uploadImage!.id ?? 0)
//                fileJSON["name"]            = JSON(myResponse.uploadImage!.name ?? "")
//                fileJSON["height"]          = JSON(myResponse.uploadImage!.height ?? 0)
//                fileJSON["width"]           = JSON(myResponse.uploadImage!.width ?? 0)
//                fileJSON["actualHeight"]    = JSON(myResponse.uploadImage!.actualHeight ?? 0)
//                fileJSON["actualWidth"]     = JSON(myResponse.uploadImage!.actualWidth ?? 0)
//                fileJSON["hashCode"]        = JSON(myResponse.uploadImage!.hashCode ?? "")
//
//                metaData["file"] = fileJSON
//                paramsToSendToSendMessage["metaData"] = JSON("\(metaData)")
//
//                sendMessageWith(paramsToSendToSendMessage: paramsToSendToSendMessage)
//            }
            
        } else if let file = sendFileMessageInput.fileToSend {
            let uploadRequest = UploadFileRequestModel(dataToSend:      file,
                                                       fileExtension:   fileExtension,
                                                       fileName:        sendFileMessageInput.fileName ?? "defaultName",
                                                       fileSize:        fileSize,
                                                       originalFileName: sendFileMessageInput.fileName ?? uploadUniqueId,
                                                       threadId:        sendFileMessageInput.threadId,
                                                       uniqueId:        uploadUniqueId)
            uploadFile(uploadFileInput: uploadRequest,
                       uniqueId: { _ in }, progress: { (progress) in
                uploadProgress(progress)
            }) { (response) in
                let myResponse: UploadFileModel = response as! UploadFileModel
                let link = "\(self.SERVICE_ADDRESSES.FILESERVER_ADDRESS)\(SERVICES_PATH.GET_FILE.rawValue)?fileId=\(myResponse.uploadFile!.id ?? 0)&hashCode=\(myResponse.uploadFile!.hashCode ?? "")"
                
                var fileJSON : JSON = [:]
                
                fileJSON["link"]        = JSON(link)
                fileJSON["id"]          = JSON(myResponse.uploadFile!.id ?? 0)
                fileJSON["name"]        = JSON(myResponse.uploadFile!.name ?? "")
                fileJSON["hashCode"]    = JSON(myResponse.uploadFile!.hashCode ?? "")
                
                metaData["file"] = fileJSON
//                paramsToSendToSendMessage["metaData"] = JSON("\(metaData)")
//                sendMessageWith(paramsToSendToSendMessage: paramsToSendToSendMessage)
                
                sendMessageWith(withMetaData: metaData)
            }
            
//            uploadFile(params:      paramsToSendToUpload,
//                       dataToSend:  file,
//                       uniqueId:    { _ in },
//                       progress:    { (progress) in
//                uploadProgress(progress)
//            }) { (response) in
//                let myResponse: UploadFileModel = response as! UploadFileModel
//                let link = "\(self.SERVICE_ADDRESSES.FILESERVER_ADDRESS)\(SERVICES_PATH.GET_FILE.rawValue)?fileId=\(myResponse.uploadFile!.id ?? 0)&hashCode=\(myResponse.uploadFile!.hashCode ?? "")"
//
//                var fileJSON : JSON = [:]
//
//                fileJSON["link"]        = JSON(link)
//                fileJSON["id"]          = JSON(myResponse.uploadFile!.id ?? 0)
//                fileJSON["name"]        = JSON(myResponse.uploadFile!.name ?? "")
//                fileJSON["hashCode"]    = JSON(myResponse.uploadFile!.hashCode ?? "")
//
//                metaData["file"] = fileJSON
//                paramsToSendToSendMessage["metaData"] = JSON("\(metaData)")
//
//                sendMessageWith(paramsToSendToSendMessage: paramsToSendToSendMessage)
//            }
        }
        
        // if there was no data to send, then returns an error to user
        if (sendFileMessageInput.imageToSend == nil) && (sendFileMessageInput.fileToSend == nil) {
            delegate?.chatError(errorCode:      6302,
                                errorMessage:   CHAT_ERRORS.err6302.rawValue,
                                errorResult:    nil)
        }
        
        
        // this will call when all data were uploaded and it will sends the textMessage
//        func sendMessageWith(paramsToSendToSendMessage: JSON) {
        func sendMessageWith(withMetaData: JSON) {
            let sendMessageParamModel = SendTextMessageRequestModel(content:        sendFileMessageInput.content ?? "",
                                                                    metaData:       withMetaData,
                                                                    repliedTo:      sendFileMessageInput.repliedTo,
                                                                    systemMetadata: sendFileMessageInput.metaData,
                                                                    threadId:       sendFileMessageInput.threadId,
                                                                    typeCode:       sendFileMessageInput.typeCode ?? generalTypeCode,
                                                                    uniqueId:       messageUniqueId)
            self.sendTextMessage(sendTextMessageInput: sendMessageParamModel, uniqueId: { _ in }, onSent: { (sent) in
                onSent(sent)
            }, onDelivere: { (delivered) in
                onDelivered(delivered)
            }) { (seen) in
                onSeen(seen)
            }
            
            
//            let sendMessageParamModel = SendTextMessageRequestModel(content:        paramsToSendToSendMessage["content"].stringValue,
//                                                                    metaData:       paramsToSendToSendMessage["metaData"],
//                                                                    repliedTo:      paramsToSendToSendMessage["repliedTo"].int,
//                                                                    systemMetadata: paramsToSendToSendMessage["systemMetadata"],
//                                                                    threadId:       paramsToSendToSendMessage["threadId"].intValue,
//                                                                    typeCode:       paramsToSendToSendMessage["typeCode"].string,
//                                                                    uniqueId:       paramsToSendToSendMessage["uniqueId"].string)
//            self.sendTextMessage(sendTextMessageInput: sendMessageParamModel, uniqueId: { _ in }, onSent: { (sent) in
//                onSent(sent)
//            }, onDelivere: { (delivered) in
//                onDelivered(delivered)
//            }, onSeen: { (seen) in
//                onSeen(seen)
//            })
            
        }
        
    }
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'SendFileMessageRequestModel' to get the parameters, it'll use JSON
    /*
    public func sendFileMessage(textMessagParams: JSON, fileParams: JSON, imageToSend: Data?, fileToSend: Data?, uniqueId: @escaping (String) -> (), uploadProgress: @escaping (Float) -> (), onSent: @escaping callbackTypeAlias, onDelivered: @escaping callbackTypeAlias, onSeen: @escaping callbackTypeAlias) {
        log.verbose("Try to Send File adn Message with this parameters: \n \(textMessagParams)", context: "Chat")
        
        var fileName:       String  = ""
        var fileType:       String  = ""
        var fileSize:       Int     = 0
        var fileExtension:  String  = ""
        
        if let myFileName = fileParams["fileName"].string {
            fileName = myFileName
        } else if let myImageName = fileParams["imageName"].string {
            fileName = myImageName
        }
        
        let uploadUniqueId: String = generateUUID()
        
        var metaData: JSON = [:]
        
        metaData["file"]["originalName"] = JSON(fileName)
        metaData["file"]["mimeType"] = JSON(fileType)
        metaData["file"]["size"] = JSON(fileSize)
        
        var paramsToSendToUpload: JSON = ["uniqueId": uploadUniqueId, "originalFileName": fileName]
        
        if let xC = fileParams["xC"].string {
            paramsToSendToUpload["xC"] = JSON(xC)
        }
        if let yC = fileParams["yC"].string {
            paramsToSendToUpload["yC"] = JSON(yC)
        }
        if let hC = fileParams["hC"].string {
            paramsToSendToUpload["hC"] = JSON(hC)
        }
        if let wC = fileParams["wC"].string {
            paramsToSendToUpload["wC"] = JSON(wC)
        }
        if let fileName = fileParams["fileName"].string {
            paramsToSendToUpload["fileName"] = JSON(fileName)
        } else {
            paramsToSendToUpload["fileName"] = JSON(uploadUniqueId)
        }
        if let threadId = fileParams["threadId"].int {
            paramsToSendToUpload["threadId"] = JSON(threadId)
        }
        
        
        let messageUniqueId = generateUUID()
        uniqueId(messageUniqueId)
        
        var paramsToSendToSendMessage: JSON = ["uniqueId": messageUniqueId,
                                               "typeCode": textMessagParams["typeCode"].string ?? generalTypeCode]
        
        if let subjectId = textMessagParams["subjectId"].int {
            paramsToSendToSendMessage["subjectId"] = JSON(subjectId)
        }
        if let repliedTo = textMessagParams["repliedTo"].int {
            paramsToSendToSendMessage["repliedTo"] = JSON(repliedTo)
        }
        if let content = textMessagParams["content"].string {
            paramsToSendToSendMessage["content"] = JSON(content)
        }
        if let systemMetadata = textMessagParams["metadata"].string {
            paramsToSendToSendMessage["systemMetadata"] = JSON(systemMetadata)
        }
        
        
        if let image = imageToSend {
            uploadImage(params: paramsToSendToUpload, dataToSend: image, uniqueId: { _ in }, progress: { (progress) in
                uploadProgress(progress)
            }) { (response) in
                let myResponse: UploadImageModel = response as! UploadImageModel
                let link = "\(self.SERVICE_ADDRESSES.FILESERVER_ADDRESS)\(SERVICES_PATH.GET_IMAGE.rawValue)?imageId=\(myResponse.uploadImage!.id ?? 0)&hashCode=\(myResponse.uploadImage!.hashCode ?? "")"
                metaData["file"]["link"]            = JSON(link)
                metaData["file"]["id"]              = JSON(myResponse.uploadImage!.id ?? 0)
                metaData["file"]["name"]            = JSON(myResponse.uploadImage!.name ?? "")
                metaData["file"]["height"]          = JSON(myResponse.uploadImage!.height ?? 0)
                metaData["file"]["width"]           = JSON(myResponse.uploadImage!.width ?? 0)
                metaData["file"]["actualHeight"]    = JSON(myResponse.uploadImage!.actualHeight ?? 0)
                metaData["file"]["actualWidth"]     = JSON(myResponse.uploadImage!.actualWidth ?? 0)
                metaData["file"]["hashCode"]        = JSON(myResponse.uploadImage!.hashCode ?? "")
                
                paramsToSendToSendMessage["metaData"] = JSON("\(metaData)")
                
                sendMessageWith(paramsToSendToSendMessage: paramsToSendToSendMessage)
            }
        } else if let file = fileToSend {
            uploadFile(params: paramsToSendToUpload, dataToSend: file, uniqueId: { _ in }, progress: { (progress) in
                uploadProgress(progress)
            }) { (response) in
                let myResponse: UploadFileModel = response as! UploadFileModel
                let link = "\(self.SERVICE_ADDRESSES.FILESERVER_ADDRESS)\(SERVICES_PATH.GET_FILE.rawValue)?fileId=\(myResponse.uploadFile!.id ?? 0)&hashCode=\(myResponse.uploadFile!.hashCode ?? "")"
                metaData["file"]["link"]            = JSON(link)
                metaData["file"]["id"]              = JSON(myResponse.uploadFile!.id ?? 0)
                metaData["file"]["name"]            = JSON(myResponse.uploadFile!.name ?? "")
                metaData["file"]["hashCode"]        = JSON(myResponse.uploadFile!.hashCode ?? "")
                
                paramsToSendToSendMessage["metaData"] = JSON("\(metaData)")
                
                sendMessageWith(paramsToSendToSendMessage: paramsToSendToSendMessage)
            }
        }
        
        // if there was no data to send, then returns an error to user
        if (imageToSend == nil) && (fileToSend == nil) {
            delegate?.chatError(errorCode: 6302, errorMessage: CHAT_ERRORS.err6302.rawValue, errorResult: nil)
        }
        
        
        // this will call when all data were uploaded and it will sends the textMessage
        func sendMessageWith(paramsToSendToSendMessage: JSON) {
            self.sendTextMessage(params: paramsToSendToSendMessage, uniqueId: { _ in}, onSent: { (sent) in
                onSent(sent)
            }, onDelivere: { (delivered) in
                onDelivered(delivered)
            }, onSeen: { (seen) in
                onSeen(seen)
            })
        }
        
    }
    */
    
    
    
    /*
     Reply File Message:
     
     this function is almost the same as SendFileMessage function
     */
    public func replyFileMessage(replyFileMessageInput: SendFileMessageRequestModel,
                                 uniqueId:              @escaping (String) -> (),
                                 uploadProgress:        @escaping (Float) -> (),
                                 onSent:                @escaping callbackTypeAlias,
                                 onDelivered:           @escaping callbackTypeAlias,
                                 onSeen:                @escaping callbackTypeAlias) {
        log.verbose("Try to reply File Message with this parameters: \n \(replyFileMessageInput)", context: "Chat")
        
        let messageUniqueId = replyFileMessageInput.uniqueId ?? generateUUID()
        uniqueId(messageUniqueId)
        
        let uploadUniqueId = generateUUID()
        
        // seve this message on the Cache Wait Queue,
        // so if there was an situation that response of the server to this message doesn't come, then we know that our message didn't sent correctly
        // and we will send this Queue to user on the GetHistory request,
        // now user knows which messages didn't send correctly, and can handle them
        if enableCache {
            let messageObjectToSendToQueue = QueueOfWaitFileMessagesModel(content:      replyFileMessageInput.content,
                                                                          fileName:     replyFileMessageInput.fileName,
                                                                          imageName:    replyFileMessageInput.imageName,
                                                                          metaData:     replyFileMessageInput.metaData,
                                                                          repliedTo:    replyFileMessageInput.repliedTo,
                                                                          threadId:     replyFileMessageInput.threadId,
                                                                          typeCode:     replyFileMessageInput.typeCode,
                                                                          uniqueId:     messageUniqueId,
                                                                          xC:           replyFileMessageInput.xC,
                                                                          yC:           replyFileMessageInput.yC,
                                                                          hC:           replyFileMessageInput.hC,
                                                                          wC:           replyFileMessageInput.wC,
                                                                          fileToSend:   replyFileMessageInput.fileToSend,
                                                                          imageToSend:  replyFileMessageInput.imageToSend)
            Chat.cacheDB.saveFileMessageToWaitQueue(fileMessage: messageObjectToSendToQueue)
        }
        
//        var fileName:       String  = ""
//        var fileType:       String  = ""
        var fileSize:       Int     = 0
        var fileExtension:  String  = ""
        
//        if let myFileName = replyFileMessageInput.fileName {
//            fileName = myFileName
//        } else if let myImageName = replyFileMessageInput.imageName {
//            fileName = myImageName
//        }
        
        var metaData: JSON = [:]
        metaData["file"]["originalName"] = JSON(replyFileMessageInput.fileName ?? replyFileMessageInput.imageName ?? "")
        metaData["file"]["mimeType"]    = JSON("")
        metaData["file"]["size"]        = JSON(fileSize)
        
//        var paramsToSendToUpload: JSON = ["uniqueId": uploadUniqueId, "originalFileName": fileName]
//        if let xC = replyFileMessageInput.xC {
//            paramsToSendToUpload["xC"] = JSON(xC)
//        }
//        if let yC = replyFileMessageInput.yC {
//            paramsToSendToUpload["yC"] = JSON(yC)
//        }
//        if let hC = replyFileMessageInput.hC {
//            paramsToSendToUpload["hC"] = JSON(hC)
//        }
//        if let wC = replyFileMessageInput.wC {
//            paramsToSendToUpload["wC"] = JSON(wC)
//        }
//        if let fileName = replyFileMessageInput.fileName {
//            paramsToSendToUpload["fileName"] = JSON(fileName)
//        } else {
//            paramsToSendToUpload["fileName"] = JSON(uploadUniqueId)
//        }
        //        if let threadId = replyFileMessageInput.threadId {
        //            paramsToSendToUpload["threadId"] = JSON(threadId)
        //        }
//        var paramsToSendToSendMessage: JSON = ["uniqueId": messageUniqueId,
//                                               "typeCode": replyFileMessageInput.typeCode ?? generalTypeCode]
        //        if let subjectId = replyFileMessageInput.subjectId {
        //            paramsToSendToSendMessage["subjectId"] = JSON(subjectId)
        //        }
//        if let threadId = replyFileMessageInput.threadId {
//            //            paramsToSendToSendMessage["subjectId"] = JSON(threadId)
//            paramsToSendToSendMessage["threadId"] = JSON(threadId)
//        }
//        if let repliedTo = replyFileMessageInput.repliedTo {
//            paramsToSendToSendMessage["repliedTo"] = JSON(repliedTo)
//        }
//        if let content = replyFileMessageInput.content {
//            paramsToSendToSendMessage["content"] = JSON("\(content)")
//        }
//        if let systemMetadata = replyFileMessageInput.metaData {
//            paramsToSendToSendMessage["systemMetadata"] = JSON("\(systemMetadata)")
//        }
        
        
        if let image = replyFileMessageInput.imageToSend {
            let uploadRequest = UploadImageRequestModel(dataToSend:         image,
                                                        fileExtension:      fileExtension,
                                                        fileName:           replyFileMessageInput.imageName ?? "defaultName",
                                                        fileSize:           fileSize,
                                                        originalFileName:   replyFileMessageInput.fileName ?? uploadUniqueId,
                                                        threadId:           replyFileMessageInput.threadId,
                                                        uniqueId:           uploadUniqueId,
                                                        xC:                 Int(replyFileMessageInput.xC ?? ""),
                                                        yC:                 Int(replyFileMessageInput.yC ?? ""),
                                                        hC:                 Int(replyFileMessageInput.hC ?? ""),
                                                        wC:                 Int(replyFileMessageInput.wC ?? ""))
            uploadImage(uploadImageInput: uploadRequest,
                        uniqueId: { _ in },
                        progress: { (progress) in
                            uploadProgress(progress)
            }) { (response) in
                let myResponse: UploadImageModel = response as! UploadImageModel
                let link = "\(self.SERVICE_ADDRESSES.FILESERVER_ADDRESS)\(SERVICES_PATH.GET_IMAGE.rawValue)?imageId=\(myResponse.uploadImage!.id ?? 0)&hashCode=\(myResponse.uploadImage!.hashCode ?? "")"
                metaData["file"]["link"]            = JSON(link)
                metaData["file"]["id"]              = JSON(myResponse.uploadImage!.id ?? 0)
                metaData["file"]["name"]            = JSON(myResponse.uploadImage!.name ?? "")
                metaData["file"]["height"]          = JSON(myResponse.uploadImage!.height ?? 0)
                metaData["file"]["width"]           = JSON(myResponse.uploadImage!.width ?? 0)
                metaData["file"]["actualHeight"]    = JSON(myResponse.uploadImage!.actualHeight ?? 0)
                metaData["file"]["actualWidth"]     = JSON(myResponse.uploadImage!.actualWidth ?? 0)
                metaData["file"]["hashCode"]        = JSON(myResponse.uploadImage!.hashCode ?? "")
                
//                paramsToSendToSendMessage["metaData"] = JSON("\(metaData)")
//                sendMessageWith(paramsToSendToSendMessage: paramsToSendToSendMessage)
                
                sendMessageWith(withMetaData: metaData)
            }
            
            
//            uploadImage(params: paramsToSendToUpload, dataToSend: image, uniqueId: { _ in }, progress: { (progress) in
//                uploadProgress(progress)
//            }) { (response) in
//
//                let myResponse: UploadImageModel = response as! UploadImageModel
//                let link = "\(self.SERVICE_ADDRESSES.FILESERVER_ADDRESS)\(SERVICES_PATH.GET_IMAGE.rawValue)?imageId=\(myResponse.uploadImage!.id ?? 0)&hashCode=\(myResponse.uploadImage!.hashCode ?? "")"
//                metaData["file"]["link"]            = JSON(link)
//                metaData["file"]["id"]              = JSON(myResponse.uploadImage!.id ?? 0)
//                metaData["file"]["name"]            = JSON(myResponse.uploadImage!.name ?? "")
//                metaData["file"]["height"]          = JSON(myResponse.uploadImage!.height ?? 0)
//                metaData["file"]["width"]           = JSON(myResponse.uploadImage!.width ?? 0)
//                metaData["file"]["actualHeight"]    = JSON(myResponse.uploadImage!.actualHeight ?? 0)
//                metaData["file"]["actualWidth"]     = JSON(myResponse.uploadImage!.actualWidth ?? 0)
//                metaData["file"]["hashCode"]        = JSON(myResponse.uploadImage!.hashCode ?? "")
//
//                paramsToSendToSendMessage["metaData"] = JSON("\(metaData)")
//
//                sendMessageWith(paramsToSendToSendMessage: paramsToSendToSendMessage)
//            }
            
        } else if let file = replyFileMessageInput.fileToSend {
            let uploadRequest = UploadFileRequestModel(dataToSend:      file,
                                                       fileExtension:   fileExtension,
                                                       fileName:        replyFileMessageInput.fileName ?? "defaultName",
                                                       fileSize:        fileSize,
                                                       originalFileName: replyFileMessageInput.fileName ?? uploadUniqueId,
                                                       threadId:        replyFileMessageInput.threadId,
                                                       uniqueId:        uploadUniqueId)
            uploadFile(uploadFileInput: uploadRequest,
                       uniqueId: { _ in },
                       progress: { (progress) in
                        uploadProgress(progress)
            }) { (response) in
                let myResponse: UploadFileModel = response as! UploadFileModel
                let link = "\(self.SERVICE_ADDRESSES.FILESERVER_ADDRESS)\(SERVICES_PATH.GET_FILE.rawValue)?fileId=\(myResponse.uploadFile!.id ?? 0)&hashCode=\(myResponse.uploadFile!.hashCode ?? "")"
                metaData["file"]["link"]            = JSON(link)
                metaData["file"]["id"]              = JSON(myResponse.uploadFile!.id ?? 0)
                metaData["file"]["name"]            = JSON(myResponse.uploadFile!.name ?? "")
                metaData["file"]["hashCode"]        = JSON(myResponse.uploadFile!.hashCode ?? "")
                
//                paramsToSendToSendMessage["metaData"] = JSON("\(metaData)")
//                sendMessageWith(paramsToSendToSendMessage: paramsToSendToSendMessage)
                
                sendMessageWith(withMetaData: metaData)
            }
            
//            uploadFile(params: paramsToSendToUpload, dataToSend: file, uniqueId: { _ in }, progress: { (progress) in
//                uploadProgress(progress)
//            }) { (response) in
//
//                let myResponse: UploadFileModel = response as! UploadFileModel
//                let link = "\(self.SERVICE_ADDRESSES.FILESERVER_ADDRESS)\(SERVICES_PATH.GET_FILE.rawValue)?fileId=\(myResponse.uploadFile!.id ?? 0)&hashCode=\(myResponse.uploadFile!.hashCode ?? "")"
//                metaData["file"]["link"]            = JSON(link)
//                metaData["file"]["id"]              = JSON(myResponse.uploadFile!.id ?? 0)
//                metaData["file"]["name"]            = JSON(myResponse.uploadFile!.name ?? "")
//                metaData["file"]["hashCode"]        = JSON(myResponse.uploadFile!.hashCode ?? "")
//
//                paramsToSendToSendMessage["metaData"] = JSON("\(metaData)")
//
//                sendMessageWith(paramsToSendToSendMessage: paramsToSendToSendMessage)
//            }
        }
        
        // if there was no data to send, then returns an error to user
        if (replyFileMessageInput.imageToSend == nil) && (replyFileMessageInput.fileToSend == nil) {
            delegate?.chatError(errorCode:      6302,
                                errorMessage:   CHAT_ERRORS.err6302.rawValue,
                                errorResult:    nil)
        }
        
        
        // this will call when all data were uploaded and it will sends the textMessage
//        func sendMessageWith(paramsToSendToSendMessage: JSON) {
        func sendMessageWith(withMetaData: JSON) {
            let sendMessageParamModel = SendTextMessageRequestModel(content:        replyFileMessageInput.content ?? "",
                                                                    metaData:       withMetaData,
                                                                    repliedTo:      replyFileMessageInput.repliedTo,
                                                                    systemMetadata: replyFileMessageInput.metaData,
                                                                    threadId:       replyFileMessageInput.threadId,
                                                                    typeCode:       replyFileMessageInput.typeCode ?? generalTypeCode,
                                                                    uniqueId:       messageUniqueId)
            self.sendTextMessage(sendTextMessageInput: sendMessageParamModel, uniqueId: { _ in }, onSent: { (sent) in
                onSent(sent)
            }, onDelivere: { (delivered) in
                onDelivered(delivered)
            }) { (seen) in
                onSeen(seen)
            }
            
//            let sendMessageParamModel = SendTextMessageRequestModel(content:        paramsToSendToSendMessage["content"].stringValue,
//                                                                    metaData:       paramsToSendToSendMessage["metaData"],
//                                                                    repliedTo:      paramsToSendToSendMessage["repliedTo"].int,
//                                                                    systemMetadata: paramsToSendToSendMessage["systemMetadata"],
//                                                                    threadId:       paramsToSendToSendMessage["threadId"].intValue,
//                                                                    typeCode:       paramsToSendToSendMessage["typeCode"].string,
//                                                                    uniqueId:       paramsToSendToSendMessage["uniqueId"].string)
//
//            self.sendTextMessage(sendTextMessageInput: sendMessageParamModel, uniqueId: { _ in }, onSent: { (sent) in
//                onSent(sent)
//            }, onDelivere: { (delivered) in
//                onDelivered(delivered)
//            }, onSeen: { (seen) in
//                onSeen(seen)
//            })
        }
        
    }
    
    
    
    // MARK: - Send Location Message
    
    public func sendLocationMessage(sendLocationMessageRequest: SendLocationMessageRequestModel,
                                    uniqueId:                   @escaping (String) -> (),
                                    downloadProgress:           @escaping (Float) -> (),
                                    uploadProgress:             @escaping (Float) -> (),
                                    onSent:                     @escaping callbackTypeAlias,
                                    onDelivere:                 @escaping callbackTypeAlias,
                                    onSeen:                     @escaping callbackTypeAlias) {
        
        let mapStaticImageInput = MapStaticImageRequestModel(centerLat: sendLocationMessageRequest.mapStaticCenterLat,
                                                             centerLng: sendLocationMessageRequest.mapStaticCenterLng,
                                                             height:    sendLocationMessageRequest.mapStaticHeight,
                                                             type:      sendLocationMessageRequest.mapStaticType,
                                                             width:     sendLocationMessageRequest.mapStaticWidth,
                                                             zoom:      sendLocationMessageRequest.mapStaticZoom)
        
        mapStaticImage(mapStaticImageInput: mapStaticImageInput,
                       uniqueId: { _ in },
                       progress: { (myProgress) in
            downloadProgress(myProgress)
        }) { (imageData) in
            let fileMessageInput = SendFileMessageRequestModel(fileName: nil,
                                                               imageName:   sendLocationMessageRequest.sendMessageImageName,
                                                               xC:          sendLocationMessageRequest.sendMessageXC,
                                                               yC:          sendLocationMessageRequest.sendMessageYC,
                                                               hC:          sendLocationMessageRequest.sendMessageHC,
                                                               wC:          sendLocationMessageRequest.sendMessageWC,
                                                               threadId:    sendLocationMessageRequest.sendMessageThreadId,
                                                               content:     sendLocationMessageRequest.sendMessageContent,
                                                               metaData:    sendLocationMessageRequest.sendMessageMetaData,
                                                               repliedTo:   sendLocationMessageRequest.sendMessageRepliedTo,
                                                               typeCode:    sendLocationMessageRequest.typeCode ?? self.generalTypeCode,
                                                               fileToSend:  nil,
                                                               imageToSend: (imageData as! Data),
                                                               uniqueId:    sendLocationMessageRequest.uniqueId ?? self.generateUUID())
            
//            let fileMessageInput = SendFileMessageRequestModel(fileName:    nil,
//                                                               imageName:   sendLocationMessageRequest.sendMessageImageName,
//                                                               xC:          sendLocationMessageRequest.sendMessageXC,
//                                                               yC:          sendLocationMessageRequest.sendMessageYC,
//                                                               hC:          sendLocationMessageRequest.sendMessageHC,
//                                                               wC:          sendLocationMessageRequest.sendMessageWC,
//                                                               threadId:    sendLocationMessageRequest.sendMessageThreadId,
//                                                               content:     sendLocationMessageRequest.sendMessageContent,
//                                                               metaData:    sendLocationMessageRequest.sendMessageMetaData,
//                                                               repliedTo:   sendLocationMessageRequest.sendMessageRepliedTo,
//                                                               typeCode:    sendLocationMessageRequest.sendMessageTypeCode,
//                                                               fileToSend:  nil,
//                                                               imageToSend: (imageData as! Data), uniqueId: nil)
            sendTM(params: fileMessageInput)
        }
        
        func sendTM(params: SendFileMessageRequestModel) {
            sendFileMessage(sendFileMessageInput: params, uniqueId: { (requestUniqueId) in
                uniqueId(requestUniqueId)
            }, uploadProgress: { (myProgress) in
                uploadProgress(myProgress)
            }, onSent: { (sent) in
                onSent(sent)
            }, onDelivered: { (deliver) in
                onDelivere(deliver)
            }) { (seen) in
                onSeen(seen)
            }
        }
        
    }
    
    
    // MARK: - Delete/Cancle Message
    /*
     DeleteMessage:
     delete specific message by getting message id.
     
     By calling this function, a request of type 29 (DELETE_MESSAGE) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some optional prameters as an input, as JSON or Model (depends on the function that you would use) which are:
     - subjectId:       id of the thread that you want to send messages.    (Int)
     - deleteForAll:
     - uniqueId:
     - typeCode:
     
     + Outputs:
     It has 2 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- completion:
     */
    public func deleteMessage(deleteMessageInput:   DeleteMessageRequestModel,
                              uniqueId:             @escaping (String) -> (),
                              completion:           @escaping callbackTypeAlias) {
        log.verbose("Try to request to edit message with this parameters: \n \(deleteMessageInput)", context: "Chat")
        
        let tempUniqueId = generateUUID()
        
        var content: JSON = []
        if let deleteForAll = deleteMessageInput.deleteForAll {
            content["deleteForAll"] = JSON("\(deleteForAll)")
        }
        
        
        /*
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.DELETE_MESSAGE.rawValue,
                                       "typeCode": deleteMessageInput.typeCode ?? generalTypeCode,
                                       "pushMsgType": 4,
                                       "content": content]
        
        sendMessageParams["subjectId"] = JSON(deleteMessageInput.subjectId)
        
        if let uniqueId = deleteMessageInput.uniqueId {
            sendMessageParams["uniqueId"] = JSON(uniqueId)
        }
        */
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.DELETE_MESSAGE.rawValue,
                                            content:            "\(content)",
                                            metaData:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          deleteMessageInput.subjectId,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           deleteMessageInput.typeCode ?? generalTypeCode,
                                            uniqueId:           deleteMessageInput.uniqueId ?? tempUniqueId,
                                            isCreateThreadAndSendMessage: nil)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  4)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callback:           DeleteMessageCallbacks(parameters: chatMessage),
                                callbacks:          nil,
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil) { (deleteMessageUniqueId) in
            uniqueId(deleteMessageUniqueId)
        }
        deleteMessageCallbackToUser = completion
        
    }
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'DeleteMessageRequestModel' to get the parameters, it'll use JSON
    /*
    public func deleteMessage(params: JSON, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        log.verbose("Try to request to edit message with this parameters: \n \(params)", context: "Chat")
        
        let deleteForAllVar = params["deleteForAll"]
        let content: JSON = ["deleteForAll": "\(deleteForAllVar)"]
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.DELETE_MESSAGE.rawValue,
                                       "typeCode": params["typeCode"].string ?? generalTypeCode,
                                       "pushMsgType": 4,
                                       "content": content]
        
        if let threadId = params["subjectId"].int {
            sendMessageParams["subjectId"] = JSON(threadId)
        }
        if let uniqueId = params["uniqueId"].string {
            sendMessageParams["uniqueId"] = JSON(uniqueId)
        }
        
        sendMessageWithCallback(params:         sendMessageParams,
                                callback:       DeleteMessageCallbacks(parameters: sendMessageParams),
                                callbacks:      nil,
                                sentCallback:   nil,
                                deliverCallback: nil,
                                seenCallback:   nil) { (deleteMessageUniqueId) in
            uniqueId(deleteMessageUniqueId)
        }
        deleteMessageCallbackToUser = completion
    }
    */
    
    
//    public func deleteMultipleMessages(withInputModel input:  DeleteMultipleMessagesRequestModel,
//                                       uniqueId:        @escaping (String) -> (),
//                                       completion:      @escaping callbackTypeAlias) {
//        log.verbose("Try to request to delete multiple messages with this parameters: \n \(input)", context: "Chat")
//
//        for subId in input.subjectId {
//            var content: JSON = []
//            if let deleteForAll = input.deleteForAll {
//                content["deleteForAll"] = JSON("\(deleteForAll)")
//            }
//            var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.DELETE_MESSAGE.rawValue,
//                                           "typeCode": input.typeCode ?? generalTypeCode,
//                                           "pushMsgType": 4,
//                                           "subjectId": subId,
//                                           "content": content]
//            if let uniqueId = input.uniqueId {
//                sendMessageParams["uniqueId"] = JSON(uniqueId)
//            }
//            sendMessageWithCallback(params: sendMessageParams,
//                                    callback: DeleteMessageCallbacks(parameters: sendMessageParams),
//                                    sentCallback: nil,
//                                    deliverCallback: nil,
//                                    seenCallback: nil)
//            { (deleteMessageUniqueId) in
//                uniqueId(deleteMessageUniqueId)
//            }
//
//            deleteMessageCallbackToUser = completion
//        }
//
//    }
    
    
    public func deleteMultipleMessages(deleteMessageInput:   DeleteMultipleMessagesRequestModel,
                                       uniqueId:             @escaping (String) -> (),
                                       completion:           @escaping callbackTypeAlias) {
        log.verbose("Try to request to edit message with this parameters: \n \(deleteMessageInput)", context: "Chat")
        
        var content: JSON = [:]
        if let deleteForAll = deleteMessageInput.deleteForAll {
            content["deleteForAll"] = JSON("\(deleteForAll)")
        }
        content["id"] = JSON(deleteMessageInput.messageIds)
        
        var uniqueIds: [String] = []
        
        if let uIds = deleteMessageInput.uniqueIds {
            for item in uIds {
                uniqueId(item)
                uniqueIds.append(item)
            }
            while uIds.count >= deleteMessageInput.messageIds.count {
                let newUniqueId = generateUUID()
                uniqueIds.append(newUniqueId)
                uniqueId(newUniqueId)
            }
        } else {
            for _ in deleteMessageInput.messageIds {
                let newUniqueId = generateUUID()
                uniqueIds.append(newUniqueId)
                uniqueId(newUniqueId)
            }
        }
        content["uniqueIds"] = JSON(uniqueIds)
        /*
        let sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.DELETE_MESSAGE.rawValue,
                                       "typeCode": deleteMessageInput.typeCode ?? generalTypeCode,
                                       "pushMsgType": 4,
                                       "content": content]
        */
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.DELETE_MESSAGE.rawValue,
                                            content:            "\(content)",
                                            metaData:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          nil,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           deleteMessageInput.typeCode ?? generalTypeCode,
                                            uniqueId:           nil,
                                            isCreateThreadAndSendMessage: nil)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  4)
        
        var myCallBacks: [DeleteMessageCallbacks] = []
        for _ in uniqueIds {
            myCallBacks.append(DeleteMessageCallbacks(parameters: chatMessage))
        }
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callback:           nil,
                                callbacks:          myCallBacks,
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil) { (deleteMessageUniqueId) in
            uniqueId(deleteMessageUniqueId)
        }
        deleteMessageCallbackToUser = completion
        
    }
    
    
    public func cancelSendMessage(cancelMessageInput:   CancelMessageRequestModel,
                                  completion:           @escaping (Bool) -> ()) {
        if enableCache {
            if let textUID = cancelMessageInput.textMessageUniqueId {
                Chat.cacheDB.deleteWaitTextMessage(uniqueId: textUID)
                completion(true)
            }
            if let editUID = cancelMessageInput.editMessageUniqueId {
                Chat.cacheDB.deleteWaitEditMessage(uniqueId: editUID)
                completion(true)
            }
            if let forwardUID = cancelMessageInput.forwardMessageUniqueId {
                Chat.cacheDB.deleteWaitForwardMessage(uniqueId: forwardUID)
                completion(true)
            }
            if let fileUID = cancelMessageInput.fileMessageUniqueId {
                Chat.cacheDB.deleteWaitFileMessage(uniqueId: fileUID)
                completion(true)
            }
            if let uploadImageUID = cancelMessageInput.uploadImageUniqueId {
                manageUpload(image: true, file: false, withUniqueId: uploadImageUID, withAction: .cancel) { (response, state) in
                    completion(state)
                }
            }
            if let uploadFileUID = cancelMessageInput.uploadFileUniqueId {
                manageUpload(image: false, file: true, withUniqueId: uploadFileUID, withAction: .cancel) { (response, state) in
                    completion(state)
                }
            }
        }
        
    }
    
    
    // MARK: - Get Delivery/Seen List
    /*
     MessageDeliveryList:
     list of participants that send deliver for some message id.
     
     By calling this function, a request of type 32 (GET_MESSAGE_DELEVERY_PARTICIPANTS) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some optional prameters as an input, as JSON or Model (depends on the function that you would use) which are:
     - subjectId:
     - typeCode:
     
     + Outputs:
     It has 2 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- completion:
     */
    public func messageDeliveryList(messageDeliveryListInput:   MessageDeliverySeenListRequestModel,
                                    uniqueId:                   @escaping (String) -> (),
                                    completion:                 @escaping callbackTypeAlias) {
        log.verbose("Try to request to get message deliver participants with this parameters: \n \(messageDeliveryListInput)", context: "Chat")
        
        /*
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.GET_MESSAGE_DELEVERY_PARTICIPANTS.rawValue,
                                       "typeCode": messageDeliveryListInput.typeCode ?? generalTypeCode]
        */
        
        var content: JSON = [:]
        if let count = messageDeliveryListInput.count {
            content["count"] = JSON(count)
        }
        if let offset = messageDeliveryListInput.offset {
            content["offset"] = JSON(offset)
        }
        
        //        content["typeCode"] = JSON(messageDeliveryListInput.typeCode ?? generalTypeCode)
        
        content["messageId"] = JSON(messageDeliveryListInput.messageId)
        
//        sendMessageParams["content"] = content
        
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.GET_MESSAGE_DELEVERY_PARTICIPANTS.rawValue,
                                            content:            "\(content)",
                                            metaData:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          nil,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           messageDeliveryListInput.typeCode ?? generalTypeCode,
                                            uniqueId:           nil,
                                            isCreateThreadAndSendMessage: nil)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  4)
        
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callback:           GetMessageDeliverList(parameters: chatMessage),
                                callbacks:          nil,
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil) { (messageDeliverListUniqueId) in
            uniqueId(messageDeliverListUniqueId)
        }
        getMessageDeliverListCallbackToUser = completion
        
    }
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'MessageDeliverySeenListRequestModel' to get the parameters, it'll use JSON
    /*
    public func messageDeliveryList(params: JSON, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        log.verbose("Try to request to get message deliver participants with this parameters: \n \(params)", context: "Chat")
        
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.GET_MESSAGE_DELEVERY_PARTICIPANTS.rawValue]
        
        var content: JSON = ["count": 50, "offset": 0]
        
        if let count = params["count"].int {
            if count > 0 {
                content["count"] = JSON(count)
            }
        }
        
        if let offset = params["offset"].int {
            if offset > 0 {
                content["offset"] = JSON(offset)
            }
        }
        
        if let typeCode = params["typeCode"].string {
            sendMessageParams["typeCode"] = JSON(typeCode)
        } else {
            sendMessageParams["typeCode"] = JSON(generalTypeCode)
        }
        
        //        if let subjectId = params["subjectId"].int {
        //            sendMessageParams["threadId"] = JSON(subjectId)
        //        }
        
        if let messageId = params["messageId"].int {
            content["messageId"] = JSON(messageId)
        }
        
        sendMessageParams["content"] = content
        
        sendMessageWithCallback(params:         sendMessageParams,
                                callback:       GetMessageDeliverList(parameters: sendMessageParams),
                                callbacks:      nil,
                                sentCallback:   nil,
                                deliverCallback: nil,
                                seenCallback:   nil) { (messageDeliverListUniqueId) in
            uniqueId(messageDeliverListUniqueId)
        }
        getMessageDeliverListCallbackToUser = completion
    }
    */
    
    
    /*
     MessageSeenList:
     list of participants that send seen for some message id.
     
     By calling this function, a request of type 33 (GET_MESSAGE_SEEN_PARTICIPANTS) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some optional prameters as an input, as JSON or Model (depends on the function that you would use) which are:
     - subjectId:
     - typeCode:
     
     + Outputs:
     It has 2 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- completion:
     */
    public func messageSeenList(messageSeenListInput:   MessageDeliverySeenListRequestModel,
                                uniqueId:               @escaping (String) -> (),
                                completion:             @escaping callbackTypeAlias) {
        log.verbose("Try to request to get message seen participants with this parameters: \n \(messageSeenListInput)", context: "Chat")
        
        /*
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.GET_MESSAGE_SEEN_PARTICIPANTS.rawValue]
        */
 
        var content: JSON = [:]
        content["count"] = JSON(messageSeenListInput.count ?? 50)
        content["offset"] = JSON(messageSeenListInput.offset ?? 0)
        content["typeCode"] = JSON(messageSeenListInput.typeCode ?? generalTypeCode)
        
        content["messageId"] = JSON(messageSeenListInput.messageId)
        
//        sendMessageParams["content"] = content
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.GET_MESSAGE_SEEN_PARTICIPANTS.rawValue,
                                            content:            "\(content)",
                                            metaData:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          nil,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           messageSeenListInput.typeCode ?? generalTypeCode,
                                            uniqueId:           nil,
                                            isCreateThreadAndSendMessage: nil)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  4)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callback:           GetMessageSeenList(parameters: chatMessage),
                                callbacks:          nil,
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil) { (messageSeenListUniqueId) in
            uniqueId(messageSeenListUniqueId)
        }
        getMessageSeenListCallbackToUser = completion
        
    }
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'MessageDeliverySeenListRequestModel' to get the parameters, it'll use JSON
    /*
    public func messageSeenList(params: JSON, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        log.verbose("Try to request to get message seen participants with this parameters: \n \(params)", context: "Chat")
        
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.GET_MESSAGE_SEEN_PARTICIPANTS.rawValue]
        
        var content: JSON = ["count": 50, "offset": 0]
        
        if let count = params["count"].int {
            if count > 0 {
                content["count"] = JSON(count)
            }
        }
        
        if let offset = params["offset"].int {
            if offset > 0 {
                content["offset"] = JSON(offset)
            }
        }
        
        if let typeCode = params["typeCode"].string {
            sendMessageParams["typeCode"] = JSON(typeCode)
        } else {
            sendMessageParams["typeCode"] = JSON(generalTypeCode)
        }
        
        if let messageId = params["messageId"].int {
            content["messageId"] = JSON(messageId)
        }
        
        sendMessageParams["content"] = content
        
        sendMessageWithCallback(params:         sendMessageParams,
                                callback:       GetMessageSeenList(parameters: sendMessageParams),
                                callbacks:      nil,
                                sentCallback:   nil,
                                deliverCallback: nil,
                                seenCallback:   nil) { (messageSeenListUniqueId) in
            uniqueId(messageSeenListUniqueId)
        }
        getMessageSeenListCallbackToUser = completion
        
    }
    */
    
    
    
    // MARK: - Send Signal Messages
    
    /*
     * Start Typing:
     *
     *  by calling this method, message of type "IS_TYPING" is sends to the server on every specific seconds
     *  if you want to stop it, you should call "stopTyping" method with it's "uniqueId"
     *
     *  + Access:   - Public
     *  + Inputs:
     *      - threadId:     Int
     *  + Outputs:  It has a callbacks as response:
     *      - uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     *
     */
    // TODO: create a timer and mechanism that send SignalMessage every specific seconds
    public func startTyping(threadId:   Int,
                            uniqueId:   @escaping (String) -> ()) {
        
        let requestUniqueId = generateUUID()
        uniqueId(requestUniqueId)
        let signalMessageInput = SendSignalMessageRequestModel(signalType:  SignalMessageType.IS_TYPING,
                                                               threadId:    threadId,
                                                               uniqueId:    requestUniqueId)
        
        // for every x seconds, call this function:
        startSignalMessage(input: signalMessageInput)
    }
    
    /*
     * Stop Typing:
     *
     * by calling this method, sending isTyping message will stop
     *
     *  + Access:   - Public
     *  + Inputs:
     *      - uniqueId:     String
     *  + Outputs:  _
     *
     */
    // TODO: create a mechanism that can stop sending SignalMessage by using its "uniqueId"
    public func stopTyping(uniqueId: String) {
        
    }
    
    
    
    /*
     * start Signal Message:
     *
     *  calling this method, will start to send SignalMessage to the server
     *
     *  + Access:   Private
     *  + Inputs:   SendSignalMessageRequestModel
     *  + Outputs:  _
     *
     */
    func startSignalMessage(input: SendSignalMessageRequestModel) {
        
//        switch input.signalType {
//        case .IS_TYPING:
//        case .RECORD_VOICE:
//        case .UPLOAD_FILE:
//        case .UPLOAD_PICTURE:
//        case .UPLOAD_SOUND:
//        case .UPLOAD_VIDEO:
//        }
        
        var content: JSON = [:]
        content["type"] = JSON("\(input.signalType.rawValue)")
        
        /*
         let sendSignalMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.SIGNAL_MESSAGE.rawValue,
         "content": content,
         "subjectId": input.threadId]
         */
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.SYSTEM_MESSAGE.rawValue,
                                            content:            "\(content)",
                                            metaData:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          input.threadId,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           nil,
                                            uniqueId:           input.uniqueId ?? generateUUID(),
                                            isCreateThreadAndSendMessage: nil)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  4)
        
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callback:           nil,
                                callbacks:          nil,
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil,
                                uniuqueIdCallback:  nil)
        
    }
    
    func stopSignalMessage(uniqueId: String) {
        
    }
    
    
}
