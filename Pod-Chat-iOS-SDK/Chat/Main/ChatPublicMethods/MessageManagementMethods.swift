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
    
    /// GetHistory:
    /// get messages in a specific thread
    ///
    /// By calling this function, a request of type 15 (GET_HISTORY) will send throut Chat-SDK,
    /// then the responses will come back as callbacks to the client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "GetHistoryRequestModel" to this function
    ///
    /// Outputs:
    /// - It has 9 callbacks as responses
    ///
    /// - parameter inputModel:             (input) you have to send your parameters insid this model. (GetHistoryRequestModel)
    /// - parameter uniqueId:               (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion:             (response) it will returns the response that comes from server to this request. (Any as! GetHistoryModel)
    /// - parameter cacheResponse:          (response) there is another response that comes from CacheDB to the user, if user has set 'enableCache' vaiable to be true. (GetHistoryModel)
    /// - parameter textMessagesNotSent:    (response) it will returns the Test Messages that has not been Sent yet! ([QueueOfWaitTextMessagesModel])
    /// - parameter editMessagesNotSent:    (response) it will returns the Edit Messages requests that has not been Sent yet! ([QueueOfWaitEditMessagesModel])
    /// - parameter forwardMessagesNotSent: (response) it will returns the Forward Messages requests that has not been Sent yet! ([QueueOfWaitForwardMessagesModel])
    /// - parameter fileMessagesNotSent:    (response) it will returns the File Messages requests that has not been Sent yet! ([QueueOfWaitFileMessagesModel])
    /// - parameter uploadImageNotSent:     (response) it will returns the Upload Image requests that has not been Sent yet! ([QueueOfWaitUploadImagesModel])
    /// - parameter uploadFileNotSent:      (response) it will returns the Upload File requests that has not been Sent yet! ([QueueOfWaitUploadFilesModel])
    public func getHistory(inputModel getHistoryInput:         GetHistoryRequestModel,
                           uniqueId:                @escaping ((String) -> ()),
                           completion:              @escaping callbackTypeAlias,
                           cacheResponse:           @escaping ((GetHistoryModel) -> ()),
                           textMessagesNotSent:     @escaping (([QueueOfWaitTextMessagesModel]) -> ()),
                           editMessagesNotSent:     @escaping (([QueueOfWaitEditMessagesModel]) -> ()),
                           forwardMessagesNotSent:  @escaping (([QueueOfWaitForwardMessagesModel]) -> ()),
                           fileMessagesNotSent:     @escaping (([QueueOfWaitFileMessagesModel]) -> ()),
                           uploadImageNotSent:      @escaping (([QueueOfWaitUploadImagesModel]) -> ()),
                           uploadFileNotSent:       @escaping (([QueueOfWaitUploadFilesModel]) -> ())) {
        
        log.verbose("Try to request to get history with this parameters: \n \(getHistoryInput)", context: "Chat")
        
        historyCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.GET_HISTORY.rawValue,
                                            content:            "\(getHistoryInput.convertContentToJSON())",
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          getHistoryInput.threadId,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           getHistoryInput.typeCode ?? generalTypeCode,
                                            uniqueId:           getHistoryInput.uniqueId ?? generateUUID(),
                                            uniqueIds:          nil,
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
       
//         if cache is enabled by user, first return cache result to the user
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
                                                                            firstMessageId: nil,
                                                                            fromTime:       getHistoryInput.fromTime,
                                                                            lastMessageId:  nil,
                                                                            messageId:      getHistoryInput.messageId,
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
    
    /// ClearHistory:
    /// clear all messeages inside a specifi thread
    ///
    /// By calling this function, a request of type 44 (CLEAR_HISTORY) will send throut Chat-SDK,
    /// then the responses will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "ClearHistoryRequestModel" to this function
    ///
    /// Outputs:
    /// - It has 2 callbacks as responses
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (ClearHistoryRequestModel)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion: (response) it will returns the response that comes from server to this request. (Any as! ClearHistoryModel)
    public func clearHistory(inputModel clearHistoryInput: ClearHistoryRequestModel,
                             uniqueId:          @escaping ((String) -> ()),
                             completion:        @escaping callbackTypeAlias) {
        
        log.verbose("Try to request to create clear history with this parameters: \n \(clearHistoryInput)", context: "Chat")
  
        clearHistoryCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.CLEAR_HISTORY.rawValue,
                                            content:            "\(clearHistoryInput.convertContentToJSON())",
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          clearHistoryInput.threadId,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           clearHistoryInput.typeCode ?? generalTypeCode,
                                            uniqueId:           clearHistoryInput.uniqueId ?? generateUUID(),
                                            uniqueIds:          nil,
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
    
    /// SendTextMessage:
    /// send a text to somebody.
    ///
    /// By calling this function, a request of type 2 (MESSAGE) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "SendTextMessageRequestModel" to this function
    ///
    /// Outputs:
    /// - It has 4 callbacks as response:
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (SendTextMessageRequestModel)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter onSent:     (response) it will return this response if Sent Message comes from server, means that the message is sent successfully (Any as! SendMessageModel)
    /// - parameter onDelivere: (response) it will return this response if Deliver Message comes from server, means that the message is delivered to the destination (Any as! SendMessageModel)
    /// - parameter onSeen:     (response) it will return this response if Seen Message comes from server, means that the message is seen by the destination (Any as! SendMessageModel)
    public func sendTextMessage(inputModel sendTextMessageInput:    SendTextMessageRequestModel,
                                uniqueId:               @escaping ((String) -> ()),
                                onSent:                 @escaping callbackTypeAlias,
                                onDelivere:             @escaping callbackTypeAlias,
                                onSeen:                 @escaping callbackTypeAlias) {
        log.verbose("Try to send Message with this parameters: \n \(sendTextMessageInput)", context: "Chat")
        
        stopTyping()
        sendCallbackToUserOnSent = onSent
        sendCallbackToUserOnDeliver = onDelivere
        sendCallbackToUserOnSeen = onSeen
        
        let tempUniqueId = sendTextMessageInput.uniqueId ?? generateUUID()
        
        /**
         seve this message on the Cache Wait Queue,
         so if there was an situation that response of the server to this message doesn't come,
         then we know that our message didn't sent correctly
         and we will send this Queue to user on the GetHistory request,
         now user knows which messages didn't send correctly, and can handle them
         */
        if enableCache {
            let messageObjectToSendToQueue = QueueOfWaitTextMessagesModel(content:          sendTextMessageInput.content,
//                                                                          metadata:         sendTextMessageInput.metadata,
                                                                          metadata:         (sendTextMessageInput.metadata != nil) ? "\(sendTextMessageInput.metadata)" : nil,
                                                                          repliedTo:        sendTextMessageInput.repliedTo,
//                                                                          systemMetadata:   sendTextMessageInput.systemMetadata,
                                                                          systemMetadata:   (sendTextMessageInput.systemMetadata != nil) ? "\(sendTextMessageInput.systemMetadata)" : nil,
                                                                          threadId:         sendTextMessageInput.threadId,
                                                                          typeCode:         sendTextMessageInput.typeCode,
                                                                          uniqueId:         tempUniqueId)
            Chat.cacheDB.saveTextMessageToWaitQueue(textMessage: messageObjectToSendToQueue)
        }
        
        let messageTxtContent = MakeCustomTextToSend(message: sendTextMessageInput.content).replaceSpaceEnterWithSpecificCharecters()
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.MESSAGE.rawValue,
                                            content:            messageTxtContent,
                                            metadata:           (sendTextMessageInput.metadata != nil) ? "\(sendTextMessageInput.metadata!)" : nil,
                                            repliedTo:          sendTextMessageInput.repliedTo,
                                            systemMetadata:     (sendTextMessageInput.systemMetadata != nil) ? "\(sendTextMessageInput.systemMetadata!)" : nil,
                                            subjectId:          sendTextMessageInput.threadId,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           sendTextMessageInput.typeCode ?? generalTypeCode,
                                            uniqueId:           tempUniqueId,
                                            uniqueIds:          nil,
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
        
    }
    
    
    /// SendInteractiveMessage:
    /// send a botMessage.
    ///
    /// By calling this function, a request of type 40 (BOT_MESSAGE) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "SendInteractiveMessageRequestModel" to this function
    ///
    /// Outputs:
    /// - It has 4 callbacks as response:
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (SendInteractiveMessageRequestModel)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter onSent:     (response) it will return this response if Sent Message comes from server, means that the message is sent successfully (Any as! SendMessageModel)
    /// - parameter onDelivere: (response) it will return this response if Deliver Message comes from server, means that the message is delivered to the destination (Any as! SendMessageModel)
    /// - parameter onSeen:     (response) it will return this response if Seen Message comes from server, means that the message is seen by the destination (Any as! SendMessageModel)
    public func sendInteractiveMessage(inputModel sendInterActiveMessageInput:  SendInteractiveMessageRequestModel,
                                       uniqueId:    @escaping ((String) -> ()),
                                       onSent:      @escaping callbackTypeAlias,
                                       onDelivered: @escaping callbackTypeAlias,
                                       onSeen:      @escaping callbackTypeAlias) {
        log.verbose("Try to send BotMessage with this parameters: \n \(sendInterActiveMessageInput)", context: "Chat")
        
        stopTyping()
        sendCallbackToUserOnSent = onSent
        sendCallbackToUserOnDeliver = onDelivered
        sendCallbackToUserOnSeen = onSeen
        
        let tempUniqueId = sendInterActiveMessageInput.uniqueId ?? generateUUID()
        
        let messageTxtContent = MakeCustomTextToSend(message: sendInterActiveMessageInput.content).replaceSpaceEnterWithSpecificCharecters()
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.BOT_MESSAGE.rawValue,
                                            content:            messageTxtContent,
                                            metadata:           "\(sendInterActiveMessageInput.metadata)",
                                            repliedTo:          nil,
                                            systemMetadata:     (sendInterActiveMessageInput.systemMetadata != nil) ? "\(sendInterActiveMessageInput.systemMetadata!)" : nil,
                                            subjectId:          sendInterActiveMessageInput.messageId,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           sendInterActiveMessageInput.typeCode ?? generalTypeCode,
                                            uniqueId:           tempUniqueId,
                                            uniqueIds:          nil,
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
        
    }
    
    
    /// EditTextMessage:
    /// edit text of a messae.
    ///
    /// By calling this function, a request of type 28 (EDIT_MESSAGE) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "EditTextMessageRequestModel" to this function
    ///
    /// Outputs:
    /// - It has 2 callbacks as response:
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (EditTextMessageRequestModel)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion: (response) it will returns the response that comes from server to this request. (Any as! EditMessageModel)
    public func editMessage(inputModel editMessageInput:   EditTextMessageRequestModel,
                            uniqueId:           @escaping ((String) -> ()),
                            completion:         @escaping callbackTypeAlias) {
        log.verbose("Try to request to edit message with this parameters: \n \(editMessageInput)", context: "Chat")
        
        stopTyping()
        editMessageCallbackToUser = completion
        
        let requestUniqueId = editMessageInput.uniqueId ?? generateUUID()
        
        /**
         seve this message on the Cache Wait Queue,
         so if there was an situation that response of the server to this message doesn't come, then we know that our message didn't sent correctly
         and we will send this Queue to user on the GetHistory request,
         now user knows which messages didn't send correctly, and can handle them
         */
        if enableCache {
            let messageObjectToSendToQueue = QueueOfWaitEditMessagesModel(content:      editMessageInput.content,
//                                                                          metadata:     editMessageInput.metadata,
                                                                          metadata:     (editMessageInput.metadata != nil) ? "\(editMessageInput.metadata!)" : nil,
                                                                          repliedTo:    editMessageInput.repliedTo,
                                                                          messageId:    editMessageInput.messageId,
                                                                          threadId:     nil,
                                                                          typeCode:     editMessageInput.typeCode,
                                                                          uniqueId:     requestUniqueId)
            Chat.cacheDB.saveEditMessageToWaitQueue(editMessage: messageObjectToSendToQueue)
        }
        
        let messageTxtContent = MakeCustomTextToSend(message: editMessageInput.content).replaceSpaceEnterWithSpecificCharecters()
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.EDIT_MESSAGE.rawValue,
                                            content:            messageTxtContent,
                                            metadata:           (editMessageInput.metadata != nil) ? "\(editMessageInput.metadata!)" : nil,
                                            repliedTo:          editMessageInput.repliedTo,
                                            systemMetadata:     nil,
                                            subjectId:          editMessageInput.messageId,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           editMessageInput.typeCode ?? generalTypeCode,
                                            uniqueId:           requestUniqueId,
                                            uniqueIds:          nil,
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
        
    }
     
    
    /// ReplyTextMessage:
    /// send reply message to a messsage.
    ///
    /// By calling this function, a request of type 2 (FORWARD_MESSAGE) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "ReplyTextMessageRequestModel" to this function
    ///
    /// Outputs:
    /// - It has 4 callbacks as response:
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (ReplyTextMessageRequestModel)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter onSent:     (response) it will return this response if Sent Message comes from server, means that the message is sent successfully (Any as! SendMessageModel)
    /// - parameter onDelivere: (response) it will return this response if Deliver Message comes from server, means that the message is delivered to the destination (Any as! SendMessageModel)
    /// - parameter onSeen:     (response) it will return this response if Seen Message comes from server, means that the message is seen by the destination (Any as! SendMessageModel)
    public func replyMessage(inputModel replyMessageInput: ReplyTextMessageRequestModel,
                             uniqueId:          @escaping ((String) -> ()),
                             onSent:            @escaping callbackTypeAlias,
                             onDelivere:        @escaping callbackTypeAlias,
                             onSeen:            @escaping callbackTypeAlias) {
        log.verbose("Try to reply Message with this parameters: \n \(replyMessageInput)", context: "Chat")
        
        stopTyping()
        sendCallbackToUserOnSent = onSent
        sendCallbackToUserOnDeliver = onDelivere
        sendCallbackToUserOnSeen = onSeen
        
        let tempUniqueId = generateUUID()
        
        /**
         seve this message on the Cache Wait Queue,
         so if there was an situation that response of the server to this message doesn't come, then we know that our message didn't sent correctly
         and we will send this Queue to user on the GetHistory request,
         now user knows which messages didn't send correctly, and can handle them
         */
        if enableCache {
            let messageObjectToSendToQueue = QueueOfWaitTextMessagesModel(content:          replyMessageInput.content,
//                                                                          metadata:         replyMessageInput.metadata,
                                                                          metadata:         (replyMessageInput.metadata != nil) ? "\(replyMessageInput.metadata!)" : nil,
                                                                          repliedTo:        replyMessageInput.repliedTo,
                                                                          systemMetadata:   nil,
                                                                          threadId:         replyMessageInput.subjectId,
                                                                          typeCode:         replyMessageInput.typeCode,
                                                                          uniqueId:         replyMessageInput.uniqueId ?? tempUniqueId)
            Chat.cacheDB.saveTextMessageToWaitQueue(textMessage: messageObjectToSendToQueue)
        }
        
        let messageTxtContent = MakeCustomTextToSend(message: replyMessageInput.content).replaceSpaceEnterWithSpecificCharecters()
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.MESSAGE.rawValue,
                                            content:            messageTxtContent,
                                            metadata:           (replyMessageInput.metadata != nil) ? "\(replyMessageInput.metadata!)" : nil,
                                            repliedTo:          replyMessageInput.repliedTo,
                                            systemMetadata:     nil,
                                            subjectId:          replyMessageInput.subjectId,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           replyMessageInput.typeCode ?? generalTypeCode,
                                            uniqueId:           replyMessageInput.uniqueId ?? tempUniqueId,
                                            uniqueIds:          nil,
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
        
    }
    
    
    /// ForwardTextMessage:
    /// forwar some messages to a thread.
    ///
    /// By calling this function, a request of type 22 (FORWARD_MESSAGE) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "ForwardMessageRequestModel" to this function
    ///
    /// Outputs:
    /// - It has 4 callbacks as response:
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (ForwardMessageRequestModel)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server.        (String)
    /// - parameter onSent:     (response) it will return this response if Sent Message comes from server, means that the message is sent successfully (Any as! SendMessageModel)
    /// - parameter onDelivere: (response) it will return this response if Deliver Message comes from server, means that the message is delivered to the destination (Any as! SendMessageModel)
    /// - parameter onSeen:     (response) it will return this response if Seen Message comes from server, means that the message is seen by the destination (Any as! SendMessageModel)
    public func forwardMessage(inputModel forwardMessageInput: ForwardMessageRequestModel,
                               uniqueIds:           @escaping ((String) -> ()),
                               onSent:              @escaping callbackTypeAlias,
                               onDelivere:          @escaping callbackTypeAlias,
                               onSeen:              @escaping callbackTypeAlias) {
        log.verbose("Try to Forward with this parameters: \n \(forwardMessageInput)", context: "Chat")
        
        /**
         seve this message on the Cache Wait Queue,
         so if there was an situation that response of the server to this message doesn't come, then we know that our message didn't sent correctly
         and we will send this Queue to user on the GetHistory request,
         now user knows which messages didn't send correctly, and can handle them
         */
        if enableCache {
            for (index, item) in forwardMessageInput.messageIds.enumerated() {
                let messageObjectToSendToQueue = QueueOfWaitForwardMessagesModel(//messageIds:    [item],
                                                                                 messageId:     item,
                                                                                 metadata:      (forwardMessageInput.metadata != nil) ? "\(forwardMessageInput.metadata!)" : nil,
                                                                                 repliedTo:     forwardMessageInput.repliedTo,
                                                                                 threadId:      forwardMessageInput.threadId,
                                                                                 typeCode:      forwardMessageInput.typeCode,
                                                                                 uniqueId:      forwardMessageInput.uniqueIds[index])
                Chat.cacheDB.saveForwardMessageToWaitQueue(forwardMessage: messageObjectToSendToQueue)
            }
        }
        
        sendCallbackToUserOnSent = onSent
        sendCallbackToUserOnDeliver = onDelivere
        sendCallbackToUserOnSeen = onSeen
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.FORWARD_MESSAGE.rawValue,
                                            content:            "\(forwardMessageInput.messageIds)",
                                            metadata:           (forwardMessageInput.metadata != nil) ? "\(forwardMessageInput.metadata!)" : nil,
                                            repliedTo:          forwardMessageInput.repliedTo,
                                            systemMetadata:     nil,
                                            subjectId:          forwardMessageInput.threadId,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           forwardMessageInput.typeCode ?? generalTypeCode,
                                            uniqueId:           nil,
                                            uniqueIds:          forwardMessageInput.uniqueIds,
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
        
    }
    
    
    // MARK: - Send/Reply File Message
    
    /// SendFileMessage:
    /// send some file and also send some message too with it.
    ///
    /// By calling this function, first an HTTP request of type (GET_IMAGE or GET_FILE), and then send message request of type 2 (MESSAGE) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "SendFileMessageRequestModel" to this function
    ///
    /// Outputs:
    /// - It has 5 callbacks as response:
    ///
    /// - parameter inputModel:     (input) you have to send your parameters insid this model. (SendFileMessageRequestModel)
    /// - parameter uniqueId:       (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter uploadProgress: (response)  it will returns the progress of the uploading request by a value between 0 and 1. (Float)
    /// - parameter onSent:         (response) it will return this response if Sent Message comes from server, means that the message is sent successfully (Any as! SendMessageModel)
    /// - parameter onDelivere:     (response) it will return this response if Deliver Message comes from server, means that the message is delivered to the destination (Any as! SendMessageModel)
    /// - parameter onSeen:         (response) it will return this response if Seen Message comes from server, means that the message is seen by the destination (Any as! SendMessageModel)
    public func sendFileMessage(inputModel sendFileMessageInput:   SendFileMessageRequestModel,
                                uniqueId:               @escaping ((String) -> ()),
                                uploadProgress:         @escaping ((Float) -> ()),
                                onSent:                 @escaping callbackTypeAlias,
                                onDelivered:            @escaping callbackTypeAlias,
                                onSeen:                 @escaping callbackTypeAlias) {
        log.verbose("Try to Send File adn Message with this parameters: \n \(sendFileMessageInput)", context: "Chat")
        
        let messageUniqueId = sendFileMessageInput.uniqueId ?? generateUUID()
        uniqueId(messageUniqueId)
        
        /**
         seve this message on the Cache Wait Queue,
         so if there was an situation that response of the server to this message doesn't come, then we know that our message didn't sent correctly
         and we will send this Queue to user on the GetHistory request,
         now user knows which messages didn't send correctly, and can handle them
         */
        if enableCache {
            let messageObjectToSendToQueue = QueueOfWaitFileMessagesModel(content:      sendFileMessageInput.content,
                                                                          fileName:     sendFileMessageInput.fileName,
                                                                          imageName:    sendFileMessageInput.imageName,
//                                                                          metadata:     sendFileMessageInput.metadata,
                                                                          metadata:     (sendFileMessageInput.metadata != nil) ? "\(sendFileMessageInput.metadata!)" : nil,
                                                                          repliedTo:    sendFileMessageInput.repliedTo,
                                                                          threadId:     sendFileMessageInput.threadId,
                                                                          xC:           sendFileMessageInput.xC,
                                                                          yC:           sendFileMessageInput.yC,
                                                                          hC:           sendFileMessageInput.hC,
                                                                          wC:           sendFileMessageInput.wC,
                                                                          fileToSend:   sendFileMessageInput.fileToSend,
                                                                          imageToSend:  sendFileMessageInput.imageToSend,
                                                                          typeCode:     sendFileMessageInput.typeCode,
                                                                          uniqueId:     messageUniqueId)
            Chat.cacheDB.saveFileMessageToWaitQueue(fileMessage: messageObjectToSendToQueue)
        }
        
//        var fileType:       String  = ""
        var fileSize:       Int     = 0
        var fileExtension:  String  = ""
        let uploadUniqueId = generateUUID()
        
        var metadata: JSON = [:]
        metadata["file"]["originalName"] = JSON(sendFileMessageInput.fileName ?? sendFileMessageInput.imageName ?? "")
        metadata["file"]["mimeType"]    = JSON("")
        metadata["file"]["size"]        = JSON(fileSize)
        
        if let image = sendFileMessageInput.imageToSend {
            let uploadRequest = UploadImageRequestModel(dataToSend:         image,
                                                        fileExtension:      fileExtension,
                                                        fileName:           sendFileMessageInput.imageName ?? "defaultName",
                                                        fileSize:           fileSize,
                                                        originalFileName:   sendFileMessageInput.fileName ?? uploadUniqueId,
                                                        threadId:           sendFileMessageInput.threadId,
                                                        xC:                 Int(sendFileMessageInput.xC ?? ""),
                                                        yC:                 Int(sendFileMessageInput.yC ?? ""),
                                                        hC:                 Int(sendFileMessageInput.hC ?? ""),
                                                        wC:                 Int(sendFileMessageInput.wC ?? ""),
                                                        typeCode:           nil,
                                                        uniqueId:           uploadUniqueId)
            uploadImage(inputModel: uploadRequest,
                        uniqueId: { _ in },
                        progress: { (progress) in
                            uploadProgress(progress)
            }) { (response) in
                let myResponse: UploadImageModel = response as! UploadImageModel
                let link = "\(self.SERVICE_ADDRESSES.FILESERVER_ADDRESS)\(SERVICES_PATH.GET_IMAGE.rawValue)?imageId=\(myResponse.uploadImage!.id ?? 0)&hashCode=\(myResponse.uploadImage!.hashCode ?? "")"
                
                var imageMetadata : JSON = [:]
                imageMetadata["link"]            = JSON(link)
                imageMetadata["id"]              = JSON(myResponse.uploadImage!.id ?? 0)
                imageMetadata["name"]            = JSON(myResponse.uploadImage!.name ?? "")
                imageMetadata["height"]          = JSON(myResponse.uploadImage!.height ?? 0)
                imageMetadata["width"]           = JSON(myResponse.uploadImage!.width ?? 0)
                imageMetadata["actualHeight"]    = JSON(myResponse.uploadImage!.actualHeight ?? 0)
                imageMetadata["actualWidth"]     = JSON(myResponse.uploadImage!.actualWidth ?? 0)
                imageMetadata["hashCode"]        = JSON(myResponse.uploadImage!.hashCode ?? "")
                metadata["file"] = imageMetadata
                
                sendMessage(withMetadata: metadata)
            }
            
        } else if let file = sendFileMessageInput.fileToSend {
            let uploadRequest = UploadFileRequestModel(dataToSend:      file,
                                                       fileExtension:   fileExtension,
                                                       fileName:        sendFileMessageInput.fileName ?? "defaultName",
                                                       fileSize:        fileSize,
                                                       originalFileName: sendFileMessageInput.fileName ?? uploadUniqueId,
                                                       threadId:        sendFileMessageInput.threadId,
                                                       typeCode:        nil,
                                                       uniqueId:        uploadUniqueId)
            uploadFile(inputModel: uploadRequest,
                       uniqueId: { _ in }, progress: { (progress) in
                uploadProgress(progress)
            }) { (response) in
                let myResponse: UploadFileModel = response as! UploadFileModel
                let link = "\(self.SERVICE_ADDRESSES.FILESERVER_ADDRESS)\(SERVICES_PATH.GET_FILE.rawValue)?fileId=\(myResponse.uploadFile!.id ?? 0)&hashCode=\(myResponse.uploadFile!.hashCode ?? "")"
                
                var fileMetadata : JSON = [:]
                fileMetadata["link"]        = JSON(link)
                fileMetadata["id"]          = JSON(myResponse.uploadFile!.id ?? 0)
                fileMetadata["name"]        = JSON(myResponse.uploadFile!.name ?? "")
                fileMetadata["hashCode"]    = JSON(myResponse.uploadFile!.hashCode ?? "")
                metadata["file"] = fileMetadata
                
                sendMessage(withMetadata: metadata)
            }
            
        }
        
        // if there was no data to send, then returns an error to user
        if (sendFileMessageInput.imageToSend == nil) && (sendFileMessageInput.fileToSend == nil) {
            delegate?.chatError(errorCode:      6302,
                                errorMessage:   CHAT_ERRORS.err6302.rawValue,
                                errorResult:    nil)
        }
        
        
        // this will call when all data were uploaded and it will sends the textMessage
        func sendMessage(withMetadata: JSON) {
            let sendMessageParamModel = SendTextMessageRequestModel(content:        sendFileMessageInput.content ?? "",
                                                                    metadata:       withMetadata,
                                                                    repliedTo:      sendFileMessageInput.repliedTo,
                                                                    systemMetadata: sendFileMessageInput.metadata,
                                                                    threadId:       sendFileMessageInput.threadId,
                                                                    typeCode:       sendFileMessageInput.typeCode ?? generalTypeCode,
                                                                    uniqueId:       messageUniqueId)
            self.sendTextMessage(inputModel: sendMessageParamModel, uniqueId: { _ in }, onSent: { (sent) in
                onSent(sent)
            }, onDelivere: { (delivered) in
                onDelivered(delivered)
            }) { (seen) in
                onSeen(seen)
            }
        }
        
    }
    
    
    /// ReplyFileMessage:
    /// this function is almost the same as SendFileMessage function
    ///
    /// By calling this function, first an HTTP request of type (GET_IMAGE or GET_FILE), and then send message request of type 2 (MESSAGE) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "SendFileMessageRequestModel" to this function
    ///
    /// Outputs:
    /// - It has 5 callbacks as response:
    ///
    /// - parameter inputModel:     (input) you have to send your parameters insid this model. (SendFileMessageRequestModel)
    /// - parameter uniqueId:       (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter uploadProgress: (response) it will returns the progress of the uploading request by a value between 0 and 1. (Float)
    /// - parameter onSent:         (response) it will return this response if Sent Message comes from server, means that the message is sent successfully (Any as! SendMessageModel)
    /// - parameter onDelivere:     (response) it will return this response if Deliver Message comes from server, means that the message is delivered to the destination (Any as! SendMessageModel)
    /// - parameter onSeen:         (response) it will return this response if Seen Message comes from server, means that the message is seen by the destination (Any as! SendMessageModel)
    public func replyFileMessage(inputModel replyFileMessageInput: SendFileMessageRequestModel,
                                 uniqueId:              @escaping ((String) -> ()),
                                 uploadProgress:        @escaping ((Float) -> ()),
                                 onSent:                @escaping callbackTypeAlias,
                                 onDelivered:           @escaping callbackTypeAlias,
                                 onSeen:                @escaping callbackTypeAlias) {
        log.verbose("Try to reply File Message with this parameters: \n \(replyFileMessageInput)", context: "Chat")
        
        let messageUniqueId = replyFileMessageInput.uniqueId ?? generateUUID()
        uniqueId(messageUniqueId)
        
        let uploadUniqueId = generateUUID()
        
        /**
         seve this message on the Cache Wait Queue,
         so if there was an situation that response of the server to this message doesn't come, then we know that our message didn't sent correctly
         and we will send this Queue to user on the GetHistory request,
         now user knows which messages didn't send correctly, and can handle them
         */
        if enableCache {
            let messageObjectToSendToQueue = QueueOfWaitFileMessagesModel(content:      replyFileMessageInput.content,
                                                                          fileName:     replyFileMessageInput.fileName,
                                                                          imageName:    replyFileMessageInput.imageName,
//                                                                          metadata:     replyFileMessageInput.metadata,
                                                                          metadata:     (replyFileMessageInput.metadata != nil) ? "\(replyFileMessageInput.metadata!)" : nil,
                                                                          repliedTo:    replyFileMessageInput.repliedTo,
                                                                          threadId:     replyFileMessageInput.threadId,
                                                                          xC:           replyFileMessageInput.xC,
                                                                          yC:           replyFileMessageInput.yC,
                                                                          hC:           replyFileMessageInput.hC,
                                                                          wC:           replyFileMessageInput.wC,
                                                                          fileToSend:   replyFileMessageInput.fileToSend,
                                                                          imageToSend:  replyFileMessageInput.imageToSend,
                                                                          typeCode:     replyFileMessageInput.typeCode,
                                                                          uniqueId:     messageUniqueId)
            Chat.cacheDB.saveFileMessageToWaitQueue(fileMessage: messageObjectToSendToQueue)
        }
        
//        var fileType:       String  = ""
        var fileSize:       Int     = 0
        var fileExtension:  String  = ""
        
        var metadata: JSON = [:]
        metadata["file"]["originalName"] = JSON(replyFileMessageInput.fileName ?? replyFileMessageInput.imageName ?? "")
        metadata["file"]["mimeType"]    = JSON("")
        metadata["file"]["size"]        = JSON(fileSize)
        
        if let image = replyFileMessageInput.imageToSend {
            let uploadRequest = UploadImageRequestModel(dataToSend:         image,
                                                        fileExtension:      fileExtension,
                                                        fileName:           replyFileMessageInput.imageName ?? "defaultName",
                                                        fileSize:           fileSize,
                                                        originalFileName:   replyFileMessageInput.fileName ?? uploadUniqueId,
                                                        threadId:           replyFileMessageInput.threadId,
                                                        xC:                 Int(replyFileMessageInput.xC ?? ""),
                                                        yC:                 Int(replyFileMessageInput.yC ?? ""),
                                                        hC:                 Int(replyFileMessageInput.hC ?? ""),
                                                        wC:                 Int(replyFileMessageInput.wC ?? ""),
                                                        typeCode:           nil,
                                                        uniqueId:           uploadUniqueId)
            uploadImage(inputModel: uploadRequest,
                        uniqueId: { _ in },
                        progress: { (progress) in
                            uploadProgress(progress)
            }) { (response) in
                let myResponse: UploadImageModel = response as! UploadImageModel
                let link = "\(self.SERVICE_ADDRESSES.FILESERVER_ADDRESS)\(SERVICES_PATH.GET_IMAGE.rawValue)?imageId=\(myResponse.uploadImage!.id ?? 0)&hashCode=\(myResponse.uploadImage!.hashCode ?? "")"
                metadata["file"]["link"]            = JSON(link)
                metadata["file"]["id"]              = JSON(myResponse.uploadImage!.id ?? 0)
                metadata["file"]["name"]            = JSON(myResponse.uploadImage!.name ?? "")
                metadata["file"]["height"]          = JSON(myResponse.uploadImage!.height ?? 0)
                metadata["file"]["width"]           = JSON(myResponse.uploadImage!.width ?? 0)
                metadata["file"]["actualHeight"]    = JSON(myResponse.uploadImage!.actualHeight ?? 0)
                metadata["file"]["actualWidth"]     = JSON(myResponse.uploadImage!.actualWidth ?? 0)
                metadata["file"]["hashCode"]        = JSON(myResponse.uploadImage!.hashCode ?? "")
                
                sendMessage(withMetadata: metadata)
            }
            
        } else if let file = replyFileMessageInput.fileToSend {
            let uploadRequest = UploadFileRequestModel(dataToSend:      file,
                                                       fileExtension:   fileExtension,
                                                       fileName:        replyFileMessageInput.fileName ?? "defaultName",
                                                       fileSize:        fileSize,
                                                       originalFileName: replyFileMessageInput.fileName ?? uploadUniqueId,
                                                       threadId:        replyFileMessageInput.threadId,
                                                       typeCode:        nil,
                                                       uniqueId:        uploadUniqueId)
            uploadFile(inputModel: uploadRequest,
                       uniqueId: { _ in },
                       progress: { (progress) in
                        uploadProgress(progress)
            }) { (response) in
                let myResponse: UploadFileModel = response as! UploadFileModel
                let link = "\(self.SERVICE_ADDRESSES.FILESERVER_ADDRESS)\(SERVICES_PATH.GET_FILE.rawValue)?fileId=\(myResponse.uploadFile!.id ?? 0)&hashCode=\(myResponse.uploadFile!.hashCode ?? "")"
                metadata["file"]["link"]            = JSON(link)
                metadata["file"]["id"]              = JSON(myResponse.uploadFile!.id ?? 0)
                metadata["file"]["name"]            = JSON(myResponse.uploadFile!.name ?? "")
                metadata["file"]["hashCode"]        = JSON(myResponse.uploadFile!.hashCode ?? "")
                
                sendMessage(withMetadata: metadata)
            }
        }
        
        // if there was no data to send, then returns an error to user
        if (replyFileMessageInput.imageToSend == nil) && (replyFileMessageInput.fileToSend == nil) {
            delegate?.chatError(errorCode:      6302,
                                errorMessage:   CHAT_ERRORS.err6302.rawValue,
                                errorResult:    nil)
        }
        
        
        // this will call when all data were uploaded and it will sends the textMessage
        func sendMessage(withMetadata: JSON) {
            let sendMessageParamModel = SendTextMessageRequestModel(content:        replyFileMessageInput.content ?? "",
                                                                    metadata:       withMetadata,
                                                                    repliedTo:      replyFileMessageInput.repliedTo,
                                                                    systemMetadata: replyFileMessageInput.metadata,
                                                                    threadId:       replyFileMessageInput.threadId,
                                                                    typeCode:       replyFileMessageInput.typeCode ?? generalTypeCode,
                                                                    uniqueId:       messageUniqueId)
            self.sendTextMessage(inputModel: sendMessageParamModel, uniqueId: { _ in }, onSent: { (sent) in
                onSent(sent)
            }, onDelivere: { (delivered) in
                onDelivered(delivered)
            }) { (seen) in
                onSeen(seen)
            }
        }
        
    }
    
    
    
    // MARK: - Send Location Message
    
    /// SendLocationMessage:
    /// send user location StaticImage by getting user location detail
    ///
    /// by calling this function, a request will send to Map ServiceCall to get user StaticImage based on its location,
    /// then send a FileMessage with this StaticImage
    ///
    /// Inputs:
    /// - you have to send your parameters as "DeleteMessageRequestModel" to this function
    ///
    /// Outputs:
    /// - It has 6 callbacks as response:
    ///
    /// - parameter inputModel:         (input) you have to send your parameters insid this model. (SendLocationMessageRequestModel)
    /// - parameter uniqueId:           (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter downloadProgress:   (response)  it will returns the progress of the downloading image from MapServices by a value between 0 and 1. (Float)
    /// - parameter uploadProgress:     (response)  it will returns the progress of the uploading image by a value between 0 and 1. (Float)
    /// - parameter onSent:             (response) it will return this response if Sent Message comes from server, means that the message is sent successfully (Any as! SendMessageModel)
    /// - parameter onDelivere:         (response) it will return this response if Deliver Message comes from server, means that the message is delivered to the destination (Any as! SendMessageModel)
    /// - parameter onSeen:             (response) it will return this response if Seen Message comes from server, means that the message is seen by the destination (Any as! SendMessageModel)
    public func sendLocationMessage(inputModel sendLocationMessageRequest: SendLocationMessageRequestModel,
                                    uniqueId:                   @escaping ((String) -> ()),
                                    downloadProgress:           @escaping ((Float) -> ()),
                                    uploadProgress:             @escaping ((Float) -> ()),
                                    onSent:                     @escaping callbackTypeAlias,
                                    onDelivere:                 @escaping callbackTypeAlias,
                                    onSeen:                     @escaping callbackTypeAlias) {
        
        let mapStaticImageInput = MapStaticImageRequestModel(centerLat: sendLocationMessageRequest.mapStaticCenterLat,
                                                             centerLng: sendLocationMessageRequest.mapStaticCenterLng,
                                                             height:    sendLocationMessageRequest.mapStaticHeight,
                                                             type:      sendLocationMessageRequest.mapStaticType,
                                                             width:     sendLocationMessageRequest.mapStaticWidth,
                                                             zoom:      sendLocationMessageRequest.mapStaticZoom)
        
        mapStaticImage(inputModel: mapStaticImageInput,
                       uniqueId: { _ in },
                       progress: { (myProgress) in
            downloadProgress(myProgress)
        }) { (imageData) in
            let fileMessageInput = SendFileMessageRequestModel(fileName:    nil,
                                                               imageName:   sendLocationMessageRequest.sendMessageImageName,
                                                               xC:          sendLocationMessageRequest.sendMessageXC,
                                                               yC:          sendLocationMessageRequest.sendMessageYC,
                                                               hC:          sendLocationMessageRequest.sendMessageHC,
                                                               wC:          sendLocationMessageRequest.sendMessageWC,
                                                               threadId:    sendLocationMessageRequest.sendMessageThreadId,
                                                               content:     sendLocationMessageRequest.sendMessageContent,
                                                               metadata:    sendLocationMessageRequest.sendMessageMetadata,
                                                               repliedTo:   sendLocationMessageRequest.sendMessageRepliedTo,
                                                               fileToSend:  nil,
                                                               imageToSend: (imageData as! Data),
                                                               typeCode:    sendLocationMessageRequest.typeCode ?? self.generalTypeCode,
                                                               uniqueId:    sendLocationMessageRequest.uniqueId ?? self.generateUUID())
            
            sendTM(params: fileMessageInput)
        }
        
        func sendTM(params: SendFileMessageRequestModel) {
            sendFileMessage(inputModel: params, uniqueId: { (requestUniqueId) in
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
    
    /// DeleteMessage:
    /// delete specific message by getting message id.
    ///
    /// By calling this function, a request of type 29 (DELETE_MESSAGE) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "DeleteMessageRequestModel" to this function
    ///
    /// Outputs:
    /// - It has 2 callbacks as response:
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (DeleteMessageRequestModel)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion: (response) it will returns the response that comes from server to this request. (Any as! DeleteMessageModel)
    public func deleteMessage(inputModel deleteMessageInput:   DeleteMessageRequestModel,
                              uniqueId:             @escaping ((String) -> ()),
                              completion:           @escaping callbackTypeAlias) {
        log.verbose("Try to request to edit message with this parameters: \n \(deleteMessageInput)", context: "Chat")
        
        var content: JSON = []
        if let deleteForAll = deleteMessageInput.deleteForAll {
            content["deleteForAll"] = JSON("\(deleteForAll)")
        }
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.DELETE_MESSAGE.rawValue,
                                            content:            "\(content)",
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          deleteMessageInput.subjectId,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           deleteMessageInput.typeCode ?? generalTypeCode,
                                            uniqueId:           deleteMessageInput.uniqueId ?? generateUUID(),
                                            uniqueIds:          nil,
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
    
    
    /// DeleteMultipleMessages:
    /// delete specific messages by getting their message ids.
    ///
    /// By calling this function, a request of type 29 (DELETE_MESSAGE) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "DeleteMultipleMessagesRequestModel" to this function
    ///
    /// Outputs:
    /// - It has 2 callbacks as response:
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (DeleteMultipleMessagesRequestModel)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server.        (String)
    /// - parameter completion: (response) it will returns the response that comes from server to this request. (Any as! DeleteMessageModel)
    public func deleteMultipleMessages(inputModel deleteMessageInput:   DeleteMultipleMessagesRequestModel,
                                       uniqueId:             @escaping ((String) -> ()),
                                       completion:           @escaping callbackTypeAlias) {
        log.verbose("Try to request to edit message with this parameters: \n \(deleteMessageInput)", context: "Chat")
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.DELETE_MESSAGE.rawValue,
                                            content:            "\(deleteMessageInput.convertContentToJSON())",
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          nil,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           deleteMessageInput.typeCode ?? generalTypeCode,
                                            uniqueId:           nil,
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: nil)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  4)
        
        var myCallBacks: [DeleteMessageCallbacks] = []
        for uId in deleteMessageInput.uniqueIds {
            myCallBacks.append(DeleteMessageCallbacks(parameters: chatMessage))
            uniqueId(uId)
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
    
    
    /// CancelSendMessage:
    /// cancel sending messages that has not been sent yet!
    ///
    /// By calling this function, we will delete the wait queue cache based on the request input
    ///
    /// Inputs:
    /// - you have to send your parameters as "CancelMessageRequestModel" to this function
    ///
    /// Outputs:
    /// - It has 1 callbacks as response:
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (CancelMessageRequestModel)
    /// - parameter completion: (response) it will returns a boolean value that if this request was successfull or not! (Bool)
    public func cancelSendMessage(inputModel cancelMessageInput:   CancelMessageRequestModel,
                                  completion:           @escaping ((Bool) -> ())) {
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
    
    /// MessageDeliveryList:
    /// list of participants that send deliver for some message id.
    ///
    /// By calling this function, a request of type 32 (GET_MESSAGE_DELEVERY_PARTICIPANTS) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "MessageDeliverySeenListRequestModel" to this function
    ///
    /// Outputs:
    /// - It has 2 callbacks as response:
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (MessageDeliverySeenListRequestModel)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion: (response) it will returns the response that comes from server to this request. (Any as! GetMessageDeliverList)
    public func messageDeliveryList(inputModel messageDeliveryListInput:   MessageDeliverySeenListRequestModel,
                                    uniqueId:                   @escaping ((String) -> ()),
                                    completion:                 @escaping callbackTypeAlias) {
        log.verbose("Try to request to get message deliver participants with this parameters: \n \(messageDeliveryListInput)", context: "Chat")
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.GET_MESSAGE_DELEVERY_PARTICIPANTS.rawValue,
                                            content:            "\(messageDeliveryListInput.convertContentToJSON())",
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          nil,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           messageDeliveryListInput.typeCode ?? generalTypeCode,
                                            uniqueId:           messageDeliveryListInput.uniqueId ?? generateUUID(),
                                            uniqueIds:          nil,
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
    
    
    /// MessageSeenList:
    /// list of participants that send seen for some message id.
    ///
    /// By calling this function, a request of type 33 (GET_MESSAGE_SEEN_PARTICIPANTS) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "MessageDeliverySeenListRequestModel" to this function
    ///
    /// Outputs:
    /// - It has 2 callbacks as response:
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (MessageDeliverySeenListRequestModel)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion: (response) it will returns the response that comes from server to this request. (Any as! GetMessageSeenList)
    public func messageSeenList(inputModel messageSeenListInput:   MessageDeliverySeenListRequestModel,
                                uniqueId:               @escaping ((String) -> ()),
                                completion:             @escaping callbackTypeAlias) {
        log.verbose("Try to request to get message seen participants with this parameters: \n \(messageSeenListInput)", context: "Chat")
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.GET_MESSAGE_SEEN_PARTICIPANTS.rawValue,
                                            content:            "\(messageSeenListInput.convertContentToJSON())",
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          nil,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           messageSeenListInput.typeCode ?? generalTypeCode,
                                            uniqueId:           messageSeenListInput.uniqueId ?? generateUUID(),
                                            uniqueIds:          nil,
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
    
    
    // MARK: - Send Signal Messages
    
    /// StartTyping:
    /// sends a message to other clients on the thread that i'm start typing
    ///
    /// by calling this method, message of type "IS_TYPING" is sends to the server on every specific seconds
    /// if you want to stop it, you should call "stopTyping" method with it's "uniqueId"
    ///
    /// Inputs:
    /// - you have to send the "threadId" that you are typing on
    ///
    /// Outputs:
    /// - It has 1 callbacks as response:
    ///
    /// - parameter threadId:   (input) the thread id that you are typing. (Int)
    /// - parameter uniqueId:   (response) it will returns a 'UniqueId' to you, that if you finished with typing you have to call "StopTyping" method with this "uniqueId" (String)
    public func startTyping(threadId:   Int,
                            uniqueId:   @escaping ((String) -> ())) {
        
        let requestUniqueId = generateUUID()
        uniqueId(requestUniqueId)
        let signalMessageInput = SendSignalMessageRequestModel(signalType:  SignalMessageType.IS_TYPING,
                                                               threadId:    threadId,
                                                               uniqueId:    requestUniqueId)
        
        if (isTyping?.threadId != 0) {
            stopTyping()
        }
        
        isTyping = (threadId: threadId, uniqueId: requestUniqueId)
        // for every x seconds, call this function:
        var counter = 0
        while (isTyping?.threadId != 0) && (counter < 15) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                self.sendSignalMessage(input: signalMessageInput)
            }
            counter += 1
        }
        if isTyping?.threadId == 0 {
            stopTyping()
            return
        }
        
//        isTypingArray.append(requestUniqueId)
//        while (isTypingArray.count > 0) {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
//                self.sendSignalMessage(input: signalMessageInput)
//            }
//        }
    }
    
    
    /// StopTyping:
    /// sends a message to other clients on the thread that i'm start typing
    ///
    /// by calling this method, sending isTyping message will stop
    ///
    /// Inputs:
    /// - this method does not have any input method
    ///
    /// Outputs:
    /// - It has no output
    public func stopTyping() {
        if let threadId = isTyping?.threadId, threadId != 0 {
            let systemEventModel = SystemEventModel(type: SystemEventTypes.STOP_TYPING, time: nil, threadId: threadId, user: nil)
            delegate?.systemEvents(model: systemEventModel)
        }
        isTyping = (0, "")
//        for (index, item) in isTypingArray.enumerated() {
//            if (item == uniqueId) {
//                isTypingArray.remove(at: index)
//                break
//            }
//        }
    }
    
    
    /**
     * send Signal Message:
     *
     *  calling this method, will start to send SignalMessage to the server
     *
     *  + Access:   Private
     *  + Inputs:   SendSignalMessageRequestModel
     *  + Outputs:  _
     *
     */
    func sendSignalMessage(input: SendSignalMessageRequestModel) {
        
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
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.SYSTEM_MESSAGE.rawValue,
                                            content:            "\(content)",
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          input.threadId,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           nil,
                                            uniqueId:           input.uniqueId ?? generateUUID(),
                                            uniqueIds:          nil,
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
    
}
