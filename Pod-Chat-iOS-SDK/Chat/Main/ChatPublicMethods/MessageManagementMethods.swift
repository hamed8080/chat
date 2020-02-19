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
        uniqueId(getHistoryInput.uniqueId)
        getHistoryCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.GET_HISTORY.rawValue,
                                            content:            "\(getHistoryInput.convertContentToJSON())",
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          getHistoryInput.threadId,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           getHistoryInput.typeCode ?? generalTypeCode,
                                            uniqueId:           getHistoryInput.uniqueId,
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: true)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  nil)
      
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callbacks:          [(GetHistoryCallbacks(parameters: chatMessage), getHistoryInput.uniqueId)],
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil)
       
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
                                                                            uniqueIds:      getHistoryInput.uniqueIds) {
                cacheResponse(cacheHistoryResult)
            }
        }
      
    }
    
    /// GetMentionList:
    /// get Mention list
    ///
    /// By calling this function, a request of type 15 (GET_HISTORY) will send throut Chat-SDK, (but it has some differencess from normal getHistory request, that its only return messages that i am mentioned on it)
    /// then the responses will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "GetMentionRequestModel" to this function
    ///
    /// Outputs:
    /// - It has 3 callbacks as responses
    ///
    /// - parameter inputModel:     (input) you have to send your parameters insid this model. (GetMentionRequestModel)
    /// - parameter uniqueId:       (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion:     (response) it will returns the response that comes from server to this request. (Any as! GetHistoryModel)
    /// - parameter cacheResponse:  (response) there is another response that comes from CacheDB to the user, if user has set 'enableCache' vaiable to be true. (GetHistoryModel)
    public func getMentionList(inputModel getMentionInput: GetMentionRequestModel,
                               uniqueId:                @escaping ((String) -> ()),
                               completion:              @escaping callbackTypeAlias,
                               cacheResponse:           @escaping ((GetHistoryModel) -> ())) {
        log.verbose("Try to request to get mention list with this parameters: \n \(getMentionInput)", context: "Chat")
        uniqueId(getMentionInput.uniqueId)
        getMentionListCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.GET_HISTORY.rawValue,
                                            content:            "\(getMentionInput.convertContentToJSON())",
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          getMentionInput.threadId,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           getMentionInput.typeCode ?? generalTypeCode,
                                            uniqueId:           getMentionInput.uniqueId,
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: true)
      
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  nil)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callbacks:          [(GetMentionCallbacks(parameters: chatMessage), getMentionInput.uniqueId)],
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil)
        
        if enableCache {
            
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
        uniqueId(clearHistoryInput.uniqueId)
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
                                            uniqueId:           clearHistoryInput.uniqueId,
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: true)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  nil)
  
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callbacks:          [(ClearHistoryCallback(parameters: chatMessage), clearHistoryInput.uniqueId)],
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil)
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
        uniqueId(sendTextMessageInput.uniqueId)
        
        stopTyping()
        sendCallbackToUserOnSent = onSent
        sendCallbackToUserOnDeliver = onDelivere
        sendCallbackToUserOnSeen = onSeen
        
        /**
         seve this message on the Cache Wait Queue,
         so if there was an situation that response of the server to this message doesn't come,
         then we know that our message didn't sent correctly
         and we will send this Queue to user on the GetHistory request,
         now user knows which messages didn't send correctly, and can handle them
         */
        if enableCache {
            let messageObjectToSendToQueue = QueueOfWaitTextMessagesModel(content:          sendTextMessageInput.content,
                                                                          metadata:         (sendTextMessageInput.metadata != nil) ? "\(sendTextMessageInput.metadata!)" : nil,
                                                                          repliedTo:        sendTextMessageInput.repliedTo,
                                                                          systemMetadata:   (sendTextMessageInput.systemMetadata != nil) ? "\(sendTextMessageInput.systemMetadata!)" : nil,
                                                                          threadId:         sendTextMessageInput.threadId,
                                                                          typeCode:         sendTextMessageInput.typeCode,
                                                                          uniqueId:         sendTextMessageInput.uniqueId)
            Chat.cacheDB.saveTextMessageToWaitQueue(textMessage: messageObjectToSendToQueue)
        }
        
//        let messageTxtContent = sendTextMessageInput.content
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
                                            uniqueId:           sendTextMessageInput.uniqueId,
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: nil)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  4)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callbacks:          nil,
                                sentCallback:       (SendMessageCallbacks(parameters: chatMessage), [sendTextMessageInput.uniqueId]),
                                deliverCallback:    (SendMessageCallbacks(parameters: chatMessage), [sendTextMessageInput.uniqueId]),
                                seenCallback:       (SendMessageCallbacks(parameters: chatMessage), [sendTextMessageInput.uniqueId]))
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
        uniqueId(sendInterActiveMessageInput.uniqueId)
        
        stopTyping()
        sendCallbackToUserOnSent = onSent
        sendCallbackToUserOnDeliver = onDelivered
        sendCallbackToUserOnSeen = onSeen
        
//        let messageTxtContent = sendInterActiveMessageInput.content
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
                                            uniqueId:           sendInterActiveMessageInput.uniqueId,
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: nil)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  4)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callbacks:          nil,
                                sentCallback:       (SendMessageCallbacks(parameters: chatMessage), [sendInterActiveMessageInput.uniqueId]),
                                deliverCallback:    (SendMessageCallbacks(parameters: chatMessage), [sendInterActiveMessageInput.uniqueId]),
                                seenCallback:       (SendMessageCallbacks(parameters: chatMessage), [sendInterActiveMessageInput.uniqueId]))
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
        uniqueId(editMessageInput.uniqueId)
        
        stopTyping()
        editMessageCallbackToUser = completion
        
        /**
         seve this message on the Cache Wait Queue,
         so if there was an situation that response of the server to this message doesn't come, then we know that our message didn't sent correctly
         and we will send this Queue to user on the GetHistory request,
         now user knows which messages didn't send correctly, and can handle them
         */
        if enableCache {
            let messageObjectToSendToQueue = QueueOfWaitEditMessagesModel(content:      editMessageInput.content,
                                                                          metadata:     (editMessageInput.metadata != nil) ? "\(editMessageInput.metadata!)" : nil,
                                                                          repliedTo:    editMessageInput.repliedTo,
                                                                          messageId:    editMessageInput.messageId,
                                                                          threadId:     nil,
                                                                          typeCode:     editMessageInput.typeCode,
                                                                          uniqueId:     editMessageInput.uniqueId)
            Chat.cacheDB.saveEditMessageToWaitQueue(editMessage: messageObjectToSendToQueue)
        }
        
//        let messageTxtContent = editMessageInput.content
        let messageTxtContent = MakeCustomTextToSend(message: editMessageInput.content).replaceSpaceEnterWithSpecificCharecters()
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.EDIT_MESSAGE.rawValue,
                                            content:            messageTxtContent,
                                            metadata:           (editMessageInput.metadata != nil) ? (editMessageInput.metadata!) : nil,
                                            repliedTo:          editMessageInput.repliedTo,
                                            systemMetadata:     nil,
                                            subjectId:          editMessageInput.messageId,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           editMessageInput.typeCode ?? generalTypeCode,
                                            uniqueId:           editMessageInput.uniqueId,
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: nil)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  4)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callbacks:          [(EditMessageCallbacks(parameters: chatMessage), editMessageInput.uniqueId)],
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil)
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
        uniqueId(replyMessageInput.uniqueId)
        
        stopTyping()
        sendCallbackToUserOnSent = onSent
        sendCallbackToUserOnDeliver = onDelivere
        sendCallbackToUserOnSeen = onSeen
        
        /**
         seve this message on the Cache Wait Queue,
         so if there was an situation that response of the server to this message doesn't come, then we know that our message didn't sent correctly
         and we will send this Queue to user on the GetHistory request,
         now user knows which messages didn't send correctly, and can handle them
         */
        if enableCache {
            let messageObjectToSendToQueue = QueueOfWaitTextMessagesModel(content:          replyMessageInput.content,
                                                                          metadata:         (replyMessageInput.metadata != nil) ? "\(replyMessageInput.metadata!)" : nil,
                                                                          repliedTo:        replyMessageInput.repliedTo,
                                                                          systemMetadata:   nil,
                                                                          threadId:         replyMessageInput.subjectId,
                                                                          typeCode:         replyMessageInput.typeCode,
                                                                          uniqueId:         replyMessageInput.uniqueId)
            Chat.cacheDB.saveTextMessageToWaitQueue(textMessage: messageObjectToSendToQueue)
        }
        
//        let messageTxtContent = replyMessageInput.content
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
                                            uniqueId:           replyMessageInput.uniqueId,
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: nil)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  4)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callbacks:          nil,
                                sentCallback:       (SendMessageCallbacks(parameters: chatMessage), [replyMessageInput.uniqueId]),
                                deliverCallback:    (SendMessageCallbacks(parameters: chatMessage), [replyMessageInput.uniqueId]),
                                seenCallback:       (SendMessageCallbacks(parameters: chatMessage), [replyMessageInput.uniqueId]))
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
                               uniqueIds:           @escaping (([String]) -> ()),
                               onSent:              @escaping callbackTypeAlias,
                               onDelivere:          @escaping callbackTypeAlias,
                               onSeen:              @escaping callbackTypeAlias) {
        
        log.verbose("Try to Forward with this parameters: \n \(forwardMessageInput)", context: "Chat")
        uniqueIds(forwardMessageInput.uniqueIds)
        
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
                                                                                 metadata:      (forwardMessageInput.metadata != nil) ? (forwardMessageInput.metadata!) : nil,
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
                                callbacks:          nil,
                                sentCallback:       (SendMessageCallbacks(parameters: chatMessage), forwardMessageInput.uniqueIds),
                                deliverCallback:    (SendMessageCallbacks(parameters: chatMessage), forwardMessageInput.uniqueIds),
                                seenCallback:       (SendMessageCallbacks(parameters: chatMessage), forwardMessageInput.uniqueIds))
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
                                uploadUniqueId:         @escaping ((String) -> ()),
                                uploadProgress:         @escaping ((Float) -> ()),
                                messageUniqueId:        @escaping ((String) -> ()),
                                onSent:                 @escaping callbackTypeAlias,
                                onDelivered:            @escaping callbackTypeAlias,
                                onSeen:                 @escaping callbackTypeAlias) {
        
        log.verbose("Try to Send File adn Message with this parameters: \n \(sendFileMessageInput)", context: "Chat")
        uploadUniqueId(sendFileMessageInput.uploadInput.uniqueId)
        messageUniqueId(sendFileMessageInput.messageInput.uniqueId)
        
        /**
         seve this message on the Cache Wait Queue,
         so if there was an situation that response of the server to this message doesn't come, then we know that our message didn't sent correctly
         and we will send this Queue to user on the GetHistory request,
         now user knows which messages didn't send correctly, and can handle them
         */
        if enableCache {
            if let file = sendFileMessageInput.uploadInput as? UploadFileRequestModel {
                let messageObjectToSendToQueue = QueueOfWaitFileMessagesModel(content:      sendFileMessageInput.messageInput.content,
                                                                              fileName:     file.fileName,
                                                                              metadata:     (sendFileMessageInput.messageInput.metadata != nil) ? "\(sendFileMessageInput.messageInput.metadata!)" : nil,
                                                                              repliedTo:    sendFileMessageInput.messageInput.repliedTo,
                                                                              threadId:     sendFileMessageInput.messageInput.threadId,
                                                                              xC:           nil,
                                                                              yC:           nil,
                                                                              hC:           nil,
                                                                              wC:           nil,
                                                                              fileToSend:   file.dataToSend,
                                                                              imageToSend:  nil,
                                                                              typeCode:     sendFileMessageInput.messageInput.typeCode,
                                                                              uniqueId:     sendFileMessageInput.messageInput.uniqueId)
                Chat.cacheDB.saveFileMessageToWaitQueue(fileMessage: messageObjectToSendToQueue)
                
            } else if let image = sendFileMessageInput.uploadInput as? UploadImageRequestModel {
                let messageObjectToSendToQueue = QueueOfWaitFileMessagesModel(content:      sendFileMessageInput.messageInput.content,
                                                                              fileName:     nil,
                                                                              metadata:     (sendFileMessageInput.messageInput.metadata != nil) ? "\(sendFileMessageInput.messageInput.metadata!)" : nil,
                                                                              repliedTo:    sendFileMessageInput.messageInput.repliedTo,
                                                                              threadId:     sendFileMessageInput.messageInput.threadId,
                                                                              xC:           image.xC,
                                                                              yC:           image.yC,
                                                                              hC:           image.hC,
                                                                              wC:           image.wC,
                                                                              fileToSend:   nil,
                                                                              imageToSend:  image.dataToSend,
                                                                              typeCode:     sendFileMessageInput.messageInput.typeCode,
                                                                              uniqueId:     sendFileMessageInput.messageInput.uniqueId)
                Chat.cacheDB.saveFileMessageToWaitQueue(fileMessage: messageObjectToSendToQueue)
            }
            
        }
        
        var fileExtension:  String  = ""
        
        var metadata: JSON = [:]
        
        if let image = sendFileMessageInput.uploadInput as? UploadImageRequestModel {
            let uploadRequest = UploadImageRequestModel(dataToSend:         image.dataToSend,
                                                        fileExtension:      fileExtension,
                                                        fileName:           image.fileName,
                                                        originalFileName:   image.originalFileName,
                                                        threadId:           image.threadId,
                                                        xC:                 image.xC,
                                                        yC:                 image.yC,
                                                        hC:                 image.hC,
                                                        wC:                 image.wC,
                                                        typeCode:           nil,
                                                        uniqueId:           image.uniqueId)
            
            metadata["file"]["originalName"] = JSON(uploadRequest.originalFileName)
            metadata["file"]["mimeType"]    = JSON("")
            metadata["file"]["size"]        = JSON(uploadRequest.fileSize)
            
            uploadImage(inputModel: uploadRequest, uniqueId: { _ in }, progress: { (progress) in
                uploadProgress(progress)
            }) { (response) in
                let myResponse: UploadImageModel = response as! UploadImageModel
                metadata["file"] = myResponse.returnMetaData(onServiceAddress: self.SERVICE_ADDRESSES.FILESERVER_ADDRESS)
                sendMessage(withMetadata: metadata)
            }
            
        } else if let file = sendFileMessageInput.uploadInput as? UploadFileRequestModel {
            let uploadRequest = UploadFileRequestModel(dataToSend:      file.dataToSend,
                                                       fileExtension:   fileExtension,
                                                       fileName:        file.fileName,
                                                       originalFileName: file.originalFileName,
                                                       threadId:        file.threadId,
                                                       typeCode:        nil,
                                                       uniqueId:        file.uniqueId)
            
            metadata["file"]["originalName"] = JSON(uploadRequest.originalFileName)
            metadata["file"]["mimeType"]    = JSON("")
            metadata["file"]["size"]        = JSON(uploadRequest.fileSize)
            
            uploadFile(inputModel: uploadRequest, uniqueId: { _ in }, progress: { (progress) in
                uploadProgress(progress)
            }) { (response) in
                let myResponse: UploadFileModel = response as! UploadFileModel
                metadata["file"]    = myResponse.returnMetaData(onServiceAddress: self.SERVICE_ADDRESSES.FILESERVER_ADDRESS)
                sendMessage(withMetadata: metadata)
            }
            
        }
        
        // this will call when all data were uploaded and it will sends the textMessage
        func sendMessage(withMetadata: JSON) {
            let sendMessageParamModel = SendTextMessageRequestModel(content:        sendFileMessageInput.messageInput.content,
                                                                    metadata:       "\(withMetadata)",
                                                                    repliedTo:      sendFileMessageInput.messageInput.repliedTo,
                                                                    systemMetadata: sendFileMessageInput.messageInput.metadata,
                                                                    threadId:       sendFileMessageInput.messageInput.threadId,
                                                                    typeCode:       sendFileMessageInput.messageInput.typeCode ?? generalTypeCode,
                                                                    uniqueId:       sendFileMessageInput.messageInput.uniqueId)
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
                                 uploadUniqueId:        @escaping ((String) -> ()),
                                 uploadProgress:        @escaping ((Float) -> ()),
                                 messageUniqueId:       @escaping ((String) -> ()),
                                 onSent:                @escaping callbackTypeAlias,
                                 onDelivered:           @escaping callbackTypeAlias,
                                 onSeen:                @escaping callbackTypeAlias) {
        log.verbose("Try to reply File Message with this parameters: \n \(replyFileMessageInput)", context: "Chat")
        
        sendFileMessage(inputModel: replyFileMessageInput, uploadUniqueId: { (uploadImageUniqueId) in
            uploadUniqueId(uploadImageUniqueId)
        }, uploadProgress: { (progress) in
            uploadProgress(progress)
        }, messageUniqueId: { (replyRequestUniqueId) in
            messageUniqueId(replyRequestUniqueId)
        }, onSent: { (sebtResponse) in
            onSent(sebtResponse)
        }, onDelivered: { (deliverResponse) in
            onDelivered(deliverResponse)
        }) { (seenResponse) in
            onSeen(seenResponse)
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
                                    downloadProgress:           @escaping ((Float) -> ()),
                                    uploadUniqueId:             @escaping ((String) -> ()),
                                    uploadProgress:             @escaping ((Float) -> ()),
                                    messageUniqueId:            @escaping ((String) -> ()),
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
            
            let uploadInput = UploadRequestModel(dataToSend:        (imageData as! Data),
                                                 fileExtension:     nil,
                                                 fileName:          sendLocationMessageRequest.sendMessageImageName,
                                                 originalFileName:  nil,
                                                 threadId:          sendLocationMessageRequest.sendMessageThreadId,
                                                 xC:                sendLocationMessageRequest.sendMessageXC,
                                                 yC:                sendLocationMessageRequest.sendMessageYC,
                                                 hC:                sendLocationMessageRequest.sendMessageHC,
                                                 wC:                sendLocationMessageRequest.sendMessageWC,
                                                 typeCode:          sendLocationMessageRequest.typeCode ?? self.generalTypeCode,
                                                 uniqueId:          sendLocationMessageRequest.uniqueId)
            
            let messageInput = SendTextMessageRequestModel(content: sendLocationMessageRequest.sendMessageContent ?? "",
                                                           metadata: sendLocationMessageRequest.sendMessageMetadata,
                                                           repliedTo: sendLocationMessageRequest.sendMessageRepliedTo,
                                                           systemMetadata: nil,
                                                           threadId: sendLocationMessageRequest.sendMessageThreadId,
                                                           typeCode: sendLocationMessageRequest.sendMessageTypeCode ?? self.generalTypeCode,
                                                           uniqueId: sendLocationMessageRequest.uniqueId)
            
            let fileMessageInput = SendFileMessageRequestModel(messageInput:    messageInput,
                                                               uploadInput:     uploadInput)
            
            sendTM(params: fileMessageInput)
        }
        
        func sendTM(params: SendFileMessageRequestModel) {
            
            sendFileMessage(inputModel: params, uploadUniqueId: { (uploadImageUniqueId) in
                uploadUniqueId(uploadImageUniqueId)
            }, uploadProgress: { (myProgress) in
                uploadProgress(myProgress)
            }, messageUniqueId: { (requestUniqueId) in
                messageUniqueId(requestUniqueId)
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
        uniqueId(deleteMessageInput.uniqueId)
        
        deleteMessageCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.DELETE_MESSAGE.rawValue,
                                            content:            "\(deleteMessageInput.convertContentToJSON())",
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          deleteMessageInput.subjectId,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           deleteMessageInput.typeCode ?? generalTypeCode,
                                            uniqueId:           deleteMessageInput.uniqueId,
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: nil)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  4)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callbacks:          [(DeleteMessageCallbacks(parameters: chatMessage), deleteMessageInput.uniqueId)],
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil)
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
                                       uniqueIds:            @escaping (([String]) -> ()),
                                       completion:           @escaping callbackTypeAlias) {
        
        log.verbose("Try to request to edit message with this parameters: \n \(deleteMessageInput)", context: "Chat")
        uniqueIds(deleteMessageInput.uniqueIds)
        
        deleteMessageCallbackToUser = completion
        
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
        
        var myCallBacks: [(DeleteMessageCallbacks, String)] = []
        for uId in deleteMessageInput.uniqueIds {
            myCallBacks.append((DeleteMessageCallbacks(parameters: chatMessage), uId))
        }
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callbacks:          myCallBacks,
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil)
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
        uniqueId(messageDeliveryListInput.uniqueId)
        
        getMessageDeliverListCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.GET_MESSAGE_DELEVERY_PARTICIPANTS.rawValue,
                                            content:            "\(messageDeliveryListInput.convertContentToJSON())",
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          nil,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           messageDeliveryListInput.typeCode ?? generalTypeCode,
                                            uniqueId:           messageDeliveryListInput.uniqueId,
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: nil)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  4)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callbacks:          [(GetMessageDeliverList(parameters: chatMessage), messageDeliveryListInput.uniqueId)],
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil)
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
        uniqueId(messageSeenListInput.uniqueId)
        
        getMessageSeenListCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.GET_MESSAGE_SEEN_PARTICIPANTS.rawValue,
                                            content:            "\(messageSeenListInput.convertContentToJSON())",
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          nil,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           messageSeenListInput.typeCode ?? generalTypeCode,
                                            uniqueId:           messageSeenListInput.uniqueId,
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: nil)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  4)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callbacks:          [(GetMessageSeenList(parameters: chatMessage), messageSeenListInput.uniqueId)],
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil)
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
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.SYSTEM_MESSAGE.rawValue,
                                            content:            "\(input.convertContentToJSON())",
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          input.threadId,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           nil,
                                            uniqueId:           input.uniqueId,
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: nil)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  4)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callbacks:          nil,
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil)
    }
    
    
    // MARK: - Pin/Unpin Message
    
    /// PinMessage:
    /// pin message on a specific thread
    ///
    /// by calling this method, message of type "PIN_MESSAGE" is sends to the sserver
    ///
    /// Inputs:
    /// - you have to send your parameters as "PinAndUnpinMessageRequestModel" to this function
    ///
    /// Outputs:
    /// - It has 2 callbacks as response:
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (PinAndUnpinMessageRequestModel)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion: (response) it will returns the response that comes from server to this request. (Any as! PinUnpinMessageModel)
    public func pinMessage(inputModel:  PinAndUnpinMessageRequestModel,
                           uniqueId:    @escaping (String) -> (),
                           completion:  @escaping callbackTypeAlias) {
            
        log.verbose("Try to request to pin message with this parameters: \n \(inputModel)", context: "Chat")
        uniqueId(inputModel.uniqueId)
        
        pinMessageCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.PIN_MESSAGE.rawValue,
                                            content:            "\(inputModel.convertContentToJSON())",
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          inputModel.messageId,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           inputModel.typeCode ?? generalTypeCode,
                                            uniqueId:           inputModel.uniqueId,
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: true)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  nil)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callbacks:          [(PinMessageCallbacks(), inputModel.uniqueId)],
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil)
    }
    
    
    /// UnpinMessage:
    /// pin message on a specific thread
    ///
    /// by calling this method, message of type "UNPIN_MESSAGE" is sends to the sserver
    ///
    /// Inputs:
    /// - you have to send your parameters as "PinAndUnpinMessageRequestModel" to this function
    ///
    /// Outputs:
    /// - It has 2 callbacks as response:
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (PinAndUnpinMessageRequestModel)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion: (response) it will returns the response that comes from server to this request. (Any as! PinUnpinMessageModel)
    public func unpinMessage(inputModel:  PinAndUnpinMessageRequestModel,
                             uniqueId:    @escaping (String) -> (),
                             completion:  @escaping callbackTypeAlias) {
            
        log.verbose("Try to request to unpin message with this parameters: \n \(inputModel)", context: "Chat")
        uniqueId(inputModel.uniqueId)
        
        unpinMessageCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.UNPIN_MESSAGE.rawValue,
                                            content:            "\(inputModel.convertContentToJSON())",
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          inputModel.messageId,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           inputModel.typeCode ?? generalTypeCode,
                                            uniqueId:           inputModel.uniqueId,
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: true)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  nil)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callbacks:          [(UnpinMessageCallbacks(), inputModel.uniqueId)],
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil)
    }
    
    
    
    
    // MARK: Resend/Remove Queue Methods
    
    public func resend(textMessages:    [QueueOfWaitTextMessagesModel],
                       uniqueId:        @escaping (String)->(),
                       sent:            @escaping (SendMessageModel)->(),
                       deliver:         @escaping (SendMessageModel)->(),
                       seen:            @escaping (SendMessageModel)->() ) {
        
        for txt in textMessages {
            let input = SendTextMessageRequestModel(content:    txt.content!,
                                                    metadata:   txt.metadata,
                                                    repliedTo:  txt.repliedTo,
                                                    systemMetadata: txt.systemMetadata,
                                                    threadId:   txt.threadId!,
                                                    typeCode: txt.typeCode,
                                                    uniqueId: txt.uniqueId)
            sendTextMessage(inputModel: input, uniqueId: { (sendTextMessageUniqueId) in
                uniqueId(sendTextMessageUniqueId)
            }, onSent: { (sentResponse) in
                sent(sentResponse as! SendMessageModel)
            }, onDelivere: { (deliverResponse) in
                deliver(deliverResponse as! SendMessageModel)
            }) { (seenResponse) in
                seen(seenResponse as! SendMessageModel)
            }
        }
        
    }
    
    public func resend(editMessages:    [QueueOfWaitEditMessagesModel],
                       uniqueId:        @escaping (String)->(),
                       completion:      @escaping (EditMessageModel)->()) {
        
        for editMsg in editMessages {
            let input = EditTextMessageRequestModel(content: editMsg.content!,
                                                    metadata: editMsg.metadata,
                                                    repliedTo: editMsg.repliedTo,
                                                    messageId: editMsg.messageId!,
                                                    typeCode: editMsg.typeCode,
                                                    uniqueId: editMsg.uniqueId)
            editMessage(inputModel: input, uniqueId: { (editTextMessageUniqueId) in
                uniqueId(editTextMessageUniqueId)
            }) { (editMessageResponse) in
                completion(editMessageResponse as! EditMessageModel)
            }
        }
        
    }
    
    public func resend(forwardMessages: [QueueOfWaitForwardMessagesModel],
                       uniqueIds:       @escaping ([String])->(),
                       sent:            @escaping (SendMessageModel)->(),
                       deliver:         @escaping (SendMessageModel)->(),
                       seen:            @escaping (SendMessageModel)->() ) {
        
        for frwrdMsg in forwardMessages {
            let input = ForwardMessageRequestModel(messageIds:  [frwrdMsg.messageId!],
                                                    metadata:    frwrdMsg.metadata,
                                                    repliedTo:   frwrdMsg.repliedTo,
                                                    threadId:    frwrdMsg.threadId!,
                                                    typeCode:    frwrdMsg.typeCode)
            forwardMessage(inputModel: input, uniqueIds: { (forwardMessageUniqueIds) in
                uniqueIds(forwardMessageUniqueIds)
            }, onSent: { (sentResponse) in
                sent(sentResponse as! SendMessageModel)
            }, onDelivere: { (deliverResponse) in
                deliver(deliverResponse as! SendMessageModel)
            }) { (seenResponse) in
                seen(seenResponse as! SendMessageModel)
            }
        }
        
    }
    
    public func resend(fileMessages:    QueueOfWaitFileMessagesModel,
                       uploadUniqueId:  @escaping (String)->(),
                       uploadProgress:  @escaping (Float)->(),
                       messageUniqueId: @escaping (String)->(),
                       sent:            @escaping (SendMessageModel)->(),
                       deliver:         @escaping (SendMessageModel)->(),
                       seen:            @escaping (SendMessageModel)->() ) {
        
        let message = SendTextMessageRequestModel(content: fileMessages.content ?? "",
                                                  metadata: fileMessages.metadata,
                                                  repliedTo: fileMessages.repliedTo,
                                                  systemMetadata: nil,
                                                  threadId: fileMessages.threadId!,
                                                  typeCode: fileMessages.typeCode,
                                                  uniqueId: fileMessages.uniqueId)
        
        var upload: UploadRequestModel? = nil
        if let fileData = fileMessages.fileToSend {
            upload = UploadRequestModel(dataToSend:         fileData,
                                        fileExtension:      nil,
                                        fileName:           fileMessages.fileName,
                                        originalFileName:   fileMessages.fileName,
                                        threadId:           fileMessages.threadId,
                                        typeCode:           fileMessages.typeCode,
                                        uniqueId:           nil)
        } else if let imageData = fileMessages.imageToSend {
            upload = UploadRequestModel(dataToSend:         imageData,
                                        fileExtension:      nil,
                                        fileName:           fileMessages.fileName,
                                        originalFileName:   fileMessages.fileName,
                                        threadId:           fileMessages.threadId!,
                                        xC:                 fileMessages.xC,
                                        yC:                 fileMessages.yC,
                                        hC:                 fileMessages.hC,
                                        wC:                 fileMessages.wC,
                                        typeCode:           fileMessages.typeCode,
                                        uniqueId:           nil)
        }
        if let theUpload = upload {
            let input = SendFileMessageRequestModel(messageInput: message, uploadInput: theUpload)
            sendFileMessage(inputModel: input, uploadUniqueId: { (thUploadUniqueId) in
                uploadUniqueId(thUploadUniqueId)
            }, uploadProgress: { (theUploadProgress) in
                uploadProgress(theUploadProgress)
            }, messageUniqueId: { (theMessageUniqueId) in
                messageUniqueId(theMessageUniqueId)
            }, onSent: { (sentResponse) in
                sent(sentResponse as! SendMessageModel)
            }, onDelivered: { (deliverResponse) in
                deliver(deliverResponse as! SendMessageModel)
            }) { (seenResponse) in
                seen(seenResponse as! SendMessageModel)
            }
        }
        
    }
    
    public func resend(uploadImageObj:  QueueOfWaitUploadImagesModel,
                       uniqueId:        @escaping (String)->(),
                       uploadProgress:  @escaping (Float)->(),
                       completion:      @escaping (UploadImageModel)->()) {
        
        let input = UploadImageRequestModel(dataToSend:     uploadImageObj.dataToSend!,
                                            fileExtension:  uploadImageObj.fileExtension,
                                            fileName:       uploadImageObj.fileName,
                                            originalFileName: nil,
                                            threadId:       uploadImageObj.threadId!,
                                            xC:             uploadImageObj.xC,
                                            yC:             uploadImageObj.yC,
                                            hC:             uploadImageObj.hC,
                                            wC:             uploadImageObj.wC,
                                            typeCode:       uploadImageObj.typeCode,
                                            uniqueId:       uploadImageObj.uniqueId)
        uploadImage(inputModel: input, uniqueId: { (uploadUniqueId) in
            uniqueId(uploadUniqueId)
        }, progress: { (theUploadProgress) in
            uploadProgress(theUploadProgress)
        }) { (uploadResponse) in
            completion(uploadResponse as! UploadImageModel)
        }
        
    }
    
    public func resend(uploadFileObj:   [QueueOfWaitUploadFilesModel],
                       uniqueId:        @escaping (String)->(),
                       uploadProgress:  @escaping (Float)->(),
                       completion:      @escaping (UploadFileModel)->()) {
        
        for upld in uploadFileObj {
            let input = UploadFileRequestModel(dataToSend:      upld.dataToSend!,
                                               fileExtension:   upld.fileExtension,
                                               fileName:        upld.fileName,
                                               originalFileName: nil,
                                               threadId:        upld.threadId!,
                                               typeCode:        upld.typeCode,
                                               uniqueId:        upld.uniqueId)
            uploadFile(inputModel: input, uniqueId: { (uploadUniqueId) in
                uniqueId(uploadUniqueId)
            }, progress: { (theUploadProgress) in
                uploadProgress(theUploadProgress)
            }) { (uploadResponse) in
                completion(uploadResponse as! UploadFileModel)
            }
        }
        
    }
    
    
//    public func removeMessageFromNotSentQueues(textMessages:       [QueueOfWaitTextMessagesModel],
//                                               editMessages:       [QueueOfWaitEditMessagesModel],
//                                               forwardMessages:    [QueueOfWaitForwardMessagesModel],
//                                               fileMessages:       [QueueOfWaitFileMessagesModel],
//                                               uploadImage:        [QueueOfWaitUploadImagesModel],
//                                               uploadFile:         [QueueOfWaitUploadFilesModel]) {
//
//        for txt in textMessages {
//            Chat.cacheDB.deleteWaitTextMessage(uniqueId: txt.uniqueId!)
//        }
//        for edt in editMessages {
//            Chat.cacheDB.deleteWaitEditMessage(uniqueId: edt.uniqueId!)
//        }
//        for frd in forwardMessages {
//            Chat.cacheDB.deleteWaitForwardMessage(uniqueId: frd.uniqueId!)
//        }
//        for flm in fileMessages {
//            Chat.cacheDB.deleteWaitFileMessage(uniqueId: flm.uniqueId!)
//        }
//        for uimg in uploadImage {
//            Chat.cacheDB.deleteWaitUploadImages(uniqueId: uimg.uniqueId!)
//        }
//        for ufl in uploadFile {
//            Chat.cacheDB.deleteWaitUploadFiles(uniqueId: ufl.uniqueId!)
//        }
//    }
    
    
    
}
