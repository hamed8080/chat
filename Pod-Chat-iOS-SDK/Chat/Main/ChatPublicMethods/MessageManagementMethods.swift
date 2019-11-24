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
    
    /**
     GetHistory:
     get messages in a thread
    
     By calling this function, a request of type 15 (GET_HISTORY) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
    
     + Inputs:
     GetHistoryRequestModel
    
     + Outputs:
     It has 9 callbacks as response:
     1- uniqueId:            it will returns the request 'UniqueId' that will send to server.        (String)
     2- completion:         it will returns the response that comes from server to this request.    (GetHistoryModel)
     3- cacheResponse:  there is another response that comes from CacheDB to the user, if user has set 'enableCache' vaiable to be true
     4- textMessagesNotSent:
     5- editMessagesNotSent:
     6- forwardMessagesNotSent:
     7- fileMessagesNotSent:
     8- uploadImageNotSent:
     9- uploadFileNotSent:
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
        
        log.verbose("Try to request to get history with this parameters: \n \(getHistoryInput)", context: "Chat")
        
        historyCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.GET_HISTORY.rawValue,
                                            content:            "\(getHistoryInput.convertContentToJSON())",
                                            metaData:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          getHistoryInput.threadId,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           getHistoryInput.requestTypeCode ?? generalTypeCode,
                                            uniqueId:           getHistoryInput.requestUniqueId ?? generateUUID(),
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
                                                                            firstMessageId: nil,
                                                                            fromTime:       getHistoryInput.fromTime,
                                                                            lastMessageId:  nil,
                                                                            messageId:      0,
                                                                            offset:         getHistoryInput.offset ?? 0,
                                                                            order:          getHistoryInput.order,
                                                                            query:          getHistoryInput.query,
                                                                            threadId:       getHistoryInput.threadId,
                                                                            toTime:         getHistoryInput.toTime,
                                                                            uniqueId:       getHistoryInput.requestUniqueId) {
                cacheResponse(cacheHistoryResult)
            }
        }
      
    }
    
    
    /**
     ClearHistory
    
     By calling this function, a request of type 44 (CLEAR_HISTORY) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     ClearHistoryRequestModel
    
     + Outputs:
     It has 2 callbacks as response:
     1- uniqueId:            it will returns the request 'UniqueId' that will send to server.        (String)
     2- completion:         it will returns the response that comes from server to this request.    (GetHistoryModel)
     */
    public func clearHistory(clearHistoryInput: ClearHistoryRequestModel,
                             uniqueId:          @escaping (String) -> (),
                             completion:        @escaping callbackTypeAlias) {
        
        log.verbose("Try to request to create clear history with this parameters: \n \(clearHistoryInput)", context: "Chat")
  
        clearHistoryCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.CLEAR_HISTORY.rawValue,
                                            content:            "\(clearHistoryInput.convertContentToJSON())",
                                            metaData:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          clearHistoryInput.threadId,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           clearHistoryInput.requestTypeCode ?? generalTypeCode,
                                            uniqueId:           clearHistoryInput.requestUniqueId ?? generateUUID(),
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
    
    /**
     SendTextMessage:
     send a text to somebody.
     
     By calling this function, a request of type 2 (MESSAGE) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     SendTextMessageRequestModel
     
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
        
        sendCallbackToUserOnSent = onSent
        sendCallbackToUserOnDeliver = onDelivere
        sendCallbackToUserOnSeen = onSeen
        
        let tempUniqueId = sendTextMessageInput.requestUniqueId ?? generateUUID()
        
        /**
         seve this message on the Cache Wait Queue,
         so if there was an situation that response of the server to this message doesn't come,
         then we know that our message didn't sent correctly
         and we will send this Queue to user on the GetHistory request,
         now user knows which messages didn't send correctly, and can handle them
         */
        if enableCache {
            let messageObjectToSendToQueue = QueueOfWaitTextMessagesModel(content:          sendTextMessageInput.content,
                                                                          metaData:         sendTextMessageInput.metaData,
                                                                          repliedTo:        sendTextMessageInput.repliedTo,
                                                                          systemMetadata:   sendTextMessageInput.systemMetadata,
                                                                          threadId:         sendTextMessageInput.threadId,
                                                                          requestTypeCode:  sendTextMessageInput.requestTypeCode,
                                                                          requestUniqueId:  tempUniqueId)
            Chat.cacheDB.saveTextMessageToWaitQueue(textMessage: messageObjectToSendToQueue)
        }
        
        let messageTxtContent = MakeCustomTextToSend(message: sendTextMessageInput.content).replaceSpaceEnterWithSpecificCharecters()
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.MESSAGE.rawValue,
                                            content:            messageTxtContent,
                                            metaData:           (sendTextMessageInput.metaData != nil) ? "\(sendTextMessageInput.metaData!)" : nil,
                                            repliedTo:          sendTextMessageInput.repliedTo,
                                            systemMetadata:     (sendTextMessageInput.systemMetadata != nil) ? "\(sendTextMessageInput.systemMetadata!)" : nil,
                                            subjectId:          sendTextMessageInput.threadId,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           sendTextMessageInput.requestTypeCode ?? generalTypeCode,
                                            uniqueId:           tempUniqueId,
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
    
    
    /**
    SendBotMessage:
    send a botMessage.
    
    By calling this function, a request of type 40 (BOT_MESSAGE) will send throut Chat-SDK,
    then the response will come back as callbacks to client whose calls this function.
    
    + Inputs:
    SendBotMessageRequestModel
    
    + Outputs:
    It has 4 callbacks as response:
    1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
    2- onSent:
    3- onDelivere:
    4- onSeen:
    */
    public func sendBotMessage(sendBotMessageInput: SendBotMessageRequestModel,
                               uniqueId:            @escaping (String) -> (),
                               onSent:              @escaping callbackTypeAlias,
                               onDelivere:          @escaping callbackTypeAlias,
                               onSeen:              @escaping callbackTypeAlias) {
        log.verbose("Try to send BotMessage with this parameters: \n \(sendBotMessageInput)", context: "Chat")
        
        sendCallbackToUserOnSent = onSent
        sendCallbackToUserOnDeliver = onDelivere
        sendCallbackToUserOnSeen = onSeen
        
        let tempUniqueId = sendBotMessageInput.requestUniqueId ?? generateUUID()
        
        if enableCache {
            let messageObjectToSendToQueue = QueueOfWaitTextMessagesModel(content:          sendBotMessageInput.content,
                                                                          metaData:         sendBotMessageInput.metaData,
                                                                          repliedTo:        sendBotMessageInput.repliedTo,
                                                                          systemMetadata:   sendBotMessageInput.systemMetadata,
                                                                          threadId:         sendBotMessageInput.receiver,
                                                                          requestTypeCode:  sendBotMessageInput.requestTypeCode,
                                                                          requestUniqueId:  tempUniqueId)
            Chat.cacheDB.saveTextMessageToWaitQueue(textMessage: messageObjectToSendToQueue)
        }
        
        let messageTxtContent = MakeCustomTextToSend(message: sendBotMessageInput.content).replaceSpaceEnterWithSpecificCharecters()
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.BOT_MESSAGE.rawValue,
                                            content:            messageTxtContent,
                                            metaData:           "\(sendBotMessageInput.metaData)",
                                            repliedTo:          sendBotMessageInput.repliedTo,
                                            systemMetadata:     (sendBotMessageInput.systemMetadata != nil) ? "\(sendBotMessageInput.systemMetadata!)" : nil,
                                            subjectId:          sendBotMessageInput.receiver,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           sendBotMessageInput.requestTypeCode ?? generalTypeCode,
                                            uniqueId:           tempUniqueId,
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
    
    
    /*
     EditTextMessage:
     edit text of a messae.
     
     By calling this function, a request of type 28 (EDIT_MESSAGE) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     EditTextMessageRequestModel
     
     + Outputs:
     It has 4 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- completion:
     */
    public func editMessage(editMessageInput:   EditTextMessageRequestModel,
                            uniqueId:           @escaping (String) -> (),
                            completion:         @escaping callbackTypeAlias) {
        log.verbose("Try to request to edit message with this parameters: \n \(editMessageInput)", context: "Chat")
        
        editMessageCallbackToUser = completion
        
        let requestUniqueId = editMessageInput.requestUniqueId ?? generateUUID()
        
        /**
         seve this message on the Cache Wait Queue,
         so if there was an situation that response of the server to this message doesn't come, then we know that our message didn't sent correctly
         and we will send this Queue to user on the GetHistory request,
         now user knows which messages didn't send correctly, and can handle them
         */
        if enableCache {
            let messageObjectToSendToQueue = QueueOfWaitEditMessagesModel(content:          editMessageInput.content,
                                                                          metaData:         editMessageInput.metaData,
                                                                          repliedTo:        editMessageInput.repliedTo,
                                                                          subjectId:        editMessageInput.subjectId,
                                                                          requestTypeCode:  editMessageInput.requestTypeCode,
                                                                          requestUniqueId:  requestUniqueId)
            Chat.cacheDB.saveEditMessageToWaitQueue(editMessage: messageObjectToSendToQueue)
        }
        
        let messageTxtContent = MakeCustomTextToSend(message: editMessageInput.content).replaceSpaceEnterWithSpecificCharecters()
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.EDIT_MESSAGE.rawValue,
                                            content:            messageTxtContent,
                                            metaData:           (editMessageInput.metaData != nil) ? "\(editMessageInput.metaData!)" : nil,
                                            repliedTo:          editMessageInput.repliedTo,
                                            systemMetadata:     nil,
                                            subjectId:          editMessageInput.subjectId,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           editMessageInput.requestTypeCode ?? generalTypeCode,
                                            uniqueId:           requestUniqueId,
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
     
    
    /**
     ReplyTextMessage:
     send reply message to a messsage.
     
     By calling this function, a request of type 2 (FORWARD_MESSAGE) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     ReplyTextMessageRequestModel
     
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
                                                                          metaData:         replyMessageInput.metaData,
                                                                          repliedTo:        replyMessageInput.repliedTo,
                                                                          systemMetadata:   nil,
                                                                          threadId:         replyMessageInput.subjectId,
                                                                          requestTypeCode:  replyMessageInput.requestTypeCode,
                                                                          requestUniqueId:  replyMessageInput.requestUniqueId ?? tempUniqueId)
            Chat.cacheDB.saveTextMessageToWaitQueue(textMessage: messageObjectToSendToQueue)
        }
        
        let messageTxtContent = MakeCustomTextToSend(message: replyMessageInput.content).replaceSpaceEnterWithSpecificCharecters()
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.MESSAGE.rawValue,
                                            content:            messageTxtContent,
                                            metaData:           (replyMessageInput.metaData != nil) ? "\(replyMessageInput.metaData!)" : nil,
                                            repliedTo:          replyMessageInput.repliedTo,
                                            systemMetadata:     nil,
                                            subjectId:          replyMessageInput.subjectId,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           replyMessageInput.requestTypeCode ?? generalTypeCode,
                                            uniqueId:           replyMessageInput.requestUniqueId ?? tempUniqueId,
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
    
    
    /**
     ForwardTextMessage:
     forwar some messages to a thread.
     
     By calling this function, a request of type 22 (FORWARD_MESSAGE) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     ForwardMessageRequestModel
     
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
        
        /**
         seve this message on the Cache Wait Queue,
         so if there was an situation that response of the server to this message doesn't come, then we know that our message didn't sent correctly
         and we will send this Queue to user on the GetHistory request,
         now user knows which messages didn't send correctly, and can handle them
         */
        if enableCache {
            let messageObjectToSendToQueue = QueueOfWaitForwardMessagesModel(messageIds:        forwardMessageInput.messageIds,
                                                                             metaData:          forwardMessageInput.metaData,
                                                                             repliedTo:         forwardMessageInput.repliedTo,
                                                                             subjectId:         forwardMessageInput.subjectId,
                                                                             requestTypeCode:   forwardMessageInput.requestTypeCode,
                                                                             requestUniqueId:   tempUniqueId)
            Chat.cacheDB.saveForwardMessageToWaitQueue(forwardMessage: messageObjectToSendToQueue)
        }
        
        let messageIdsList: [Int] = forwardMessageInput.messageIds
        var uniqueIdsList: [String] = []
        
        for _ in messageIdsList {
            
            let uID = generateUUID()
            uniqueIdsList.append(uID)
            
            sendCallbackToUserOnSent = onSent
            sendCallbackToUserOnDeliver = onDelivere
            sendCallbackToUserOnSeen = onSeen
            
            let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.FORWARD_MESSAGE.rawValue,
                                                content:            "\(messageIdsList)",
                                                metaData:           (forwardMessageInput.metaData != nil) ? "\(forwardMessageInput.metaData!)" : nil,
                                                repliedTo:          forwardMessageInput.repliedTo,
                                                systemMetadata:     nil,
                                                subjectId:          forwardMessageInput.subjectId,
                                                token:              token,
                                                tokenIssuer:        nil,
                                                typeCode:           forwardMessageInput.requestTypeCode ?? generalTypeCode,
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
        }
        
        // ToDo: upward code must be delete and this code will be the correct implementation
//        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.FORWARD_MESSAGE.rawValue,
//                                            content:            "\(messageIdsList)",
//                                            metaData:           (forwardMessageInput.metaData != nil) ? "\(forwardMessageInput.metaData!)" : nil,
//                                            repliedTo:          forwardMessageInput.repliedTo,
//                                            systemMetadata:     nil,
//                                            subjectId:          forwardMessageInput.subjectId,
//                                            token:              token,
//                                            tokenIssuer:        nil,
//                                            typeCode:           forwardMessageInput.requestTypeCode ?? generalTypeCode,
//                                            uniqueId:           uniqueIdsList.first,
//                                            isCreateThreadAndSendMessage: nil)
//
//        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
//                                              msgTTL:       msgTTL,
//                                              peerName:     serverName,
//                                              priority:     msgPriority,
//                                              pushMsgType:  4)
//
//        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
//                                callback:           nil,
//                                callbacks:          nil,
//                                sentCallback:       SendMessageCallbacks(parameters: chatMessage),
//                                deliverCallback:    SendMessageCallbacks(parameters: chatMessage),
//                                seenCallback:       SendMessageCallbacks(parameters: chatMessage)) { (theUniqueId) in
//            uniqueIds(theUniqueId)
//        }
        
    }
    
    
    // MARK: - Send/Reply File Message
    
    /**
     SendFileMessage:
     send some file and also send some message too with it.
     
     By calling this function, first an HTTP request of type (GET_IMAGE or GET_FILE), and then send message request of type 2 (MESSAGE) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     SendFileMessageRequestModel
     
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
        
        let messageUniqueId = sendFileMessageInput.requestUniqueId ?? generateUUID()
        uniqueId(messageUniqueId)
        
        /**
         seve this message on the Cache Wait Queue,
         so if there was an situation that response of the server to this message doesn't come, then we know that our message didn't sent correctly
         and we will send this Queue to user on the GetHistory request,
         now user knows which messages didn't send correctly, and can handle them
         */
        if enableCache {
            let messageObjectToSendToQueue = QueueOfWaitFileMessagesModel(content:          sendFileMessageInput.content,
                                                                          fileName:         sendFileMessageInput.fileName,
                                                                          imageName:        sendFileMessageInput.imageName,
                                                                          metaData:         sendFileMessageInput.metaData,
                                                                          repliedTo:        sendFileMessageInput.repliedTo,
                                                                          threadId:         sendFileMessageInput.threadId,
                                                                          xC:               sendFileMessageInput.xC,
                                                                          yC:               sendFileMessageInput.yC,
                                                                          hC:               sendFileMessageInput.hC,
                                                                          wC:               sendFileMessageInput.wC,
                                                                          fileToSend:       sendFileMessageInput.fileToSend,
                                                                          imageToSend:      sendFileMessageInput.imageToSend,
                                                                          requestTypeCode:  sendFileMessageInput.requestTypeCode,
                                                                          requestUniqueId:  messageUniqueId)
            Chat.cacheDB.saveFileMessageToWaitQueue(fileMessage: messageObjectToSendToQueue)
        }
        
//        var fileType:       String  = ""
        var fileSize:       Int     = 0
        var fileExtension:  String  = ""
        let uploadUniqueId = generateUUID()
        
        var metaData: JSON = [:]
        metaData["file"]["originalName"] = JSON(sendFileMessageInput.fileName ?? sendFileMessageInput.imageName ?? "")
        metaData["file"]["mimeType"]    = JSON("")
        metaData["file"]["size"]        = JSON(fileSize)
        
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
                                                        requestTypeCode:    nil,
                                                        requestUniqueId:    uploadUniqueId)
            uploadImage(uploadImageInput: uploadRequest,
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
                metaData["file"] = imageMetadata
                
                sendMessage(withMetaData: metaData)
            }
            
        } else if let file = sendFileMessageInput.fileToSend {
            let uploadRequest = UploadFileRequestModel(dataToSend:      file,
                                                       fileExtension:   fileExtension,
                                                       fileName:        sendFileMessageInput.fileName ?? "defaultName",
                                                       fileSize:        fileSize,
                                                       originalFileName: sendFileMessageInput.fileName ?? uploadUniqueId,
                                                       threadId:        sendFileMessageInput.threadId,
                                                       requestTypeCode: nil,
                                                       requestUniqueId: uploadUniqueId)
            uploadFile(uploadFileInput: uploadRequest,
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
                metaData["file"] = fileMetadata
                
                sendMessage(withMetaData: metaData)
            }
            
        }
        
        // if there was no data to send, then returns an error to user
        if (sendFileMessageInput.imageToSend == nil) && (sendFileMessageInput.fileToSend == nil) {
            delegate?.chatError(errorCode:      6302,
                                errorMessage:   CHAT_ERRORS.err6302.rawValue,
                                errorResult:    nil)
        }
        
        
        // this will call when all data were uploaded and it will sends the textMessage
        func sendMessage(withMetaData: JSON) {
            let sendMessageParamModel = SendTextMessageRequestModel(content:            sendFileMessageInput.content ?? "",
                                                                    metaData:           withMetaData,
                                                                    repliedTo:          sendFileMessageInput.repliedTo,
                                                                    systemMetadata:     sendFileMessageInput.metaData,
                                                                    threadId:           sendFileMessageInput.threadId,
                                                                    requestTypeCode:    sendFileMessageInput.requestTypeCode ?? generalTypeCode,
                                                                    requestUniqueId:    messageUniqueId)
            self.sendTextMessage(sendTextMessageInput: sendMessageParamModel, uniqueId: { _ in }, onSent: { (sent) in
                onSent(sent)
            }, onDelivere: { (delivered) in
                onDelivered(delivered)
            }) { (seen) in
                onSeen(seen)
            }
        }
        
    }
    
    
    /**
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
        
        let messageUniqueId = replyFileMessageInput.requestUniqueId ?? generateUUID()
        uniqueId(messageUniqueId)
        
        let uploadUniqueId = generateUUID()
        
        /**
         seve this message on the Cache Wait Queue,
         so if there was an situation that response of the server to this message doesn't come, then we know that our message didn't sent correctly
         and we will send this Queue to user on the GetHistory request,
         now user knows which messages didn't send correctly, and can handle them
         */
        if enableCache {
            let messageObjectToSendToQueue = QueueOfWaitFileMessagesModel(content:          replyFileMessageInput.content,
                                                                          fileName:         replyFileMessageInput.fileName,
                                                                          imageName:        replyFileMessageInput.imageName,
                                                                          metaData:         replyFileMessageInput.metaData,
                                                                          repliedTo:        replyFileMessageInput.repliedTo,
                                                                          threadId:         replyFileMessageInput.threadId,
                                                                          xC:               replyFileMessageInput.xC,
                                                                          yC:               replyFileMessageInput.yC,
                                                                          hC:               replyFileMessageInput.hC,
                                                                          wC:               replyFileMessageInput.wC,
                                                                          fileToSend:       replyFileMessageInput.fileToSend,
                                                                          imageToSend:      replyFileMessageInput.imageToSend,
                                                                          requestTypeCode:  replyFileMessageInput.requestTypeCode,
                                                                          requestUniqueId:  messageUniqueId)
            Chat.cacheDB.saveFileMessageToWaitQueue(fileMessage: messageObjectToSendToQueue)
        }
        
//        var fileType:       String  = ""
        var fileSize:       Int     = 0
        var fileExtension:  String  = ""
        
        var metaData: JSON = [:]
        metaData["file"]["originalName"] = JSON(replyFileMessageInput.fileName ?? replyFileMessageInput.imageName ?? "")
        metaData["file"]["mimeType"]    = JSON("")
        metaData["file"]["size"]        = JSON(fileSize)
        
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
                                                        requestTypeCode:    nil,
                                                        requestUniqueId:    uploadUniqueId)
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
                
                sendMessage(withMetaData: metaData)
            }
            
        } else if let file = replyFileMessageInput.fileToSend {
            let uploadRequest = UploadFileRequestModel(dataToSend:      file,
                                                       fileExtension:   fileExtension,
                                                       fileName:        replyFileMessageInput.fileName ?? "defaultName",
                                                       fileSize:        fileSize,
                                                       originalFileName: replyFileMessageInput.fileName ?? uploadUniqueId,
                                                       threadId:        replyFileMessageInput.threadId,
                                                       requestTypeCode: nil,
                                                       requestUniqueId: uploadUniqueId)
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
                
                sendMessage(withMetaData: metaData)
            }
        }
        
        // if there was no data to send, then returns an error to user
        if (replyFileMessageInput.imageToSend == nil) && (replyFileMessageInput.fileToSend == nil) {
            delegate?.chatError(errorCode:      6302,
                                errorMessage:   CHAT_ERRORS.err6302.rawValue,
                                errorResult:    nil)
        }
        
        
        // this will call when all data were uploaded and it will sends the textMessage
        func sendMessage(withMetaData: JSON) {
            let sendMessageParamModel = SendTextMessageRequestModel(content:            replyFileMessageInput.content ?? "",
                                                                    metaData:           withMetaData,
                                                                    repliedTo:          replyFileMessageInput.repliedTo,
                                                                    systemMetadata:     replyFileMessageInput.metaData,
                                                                    threadId:           replyFileMessageInput.threadId,
                                                                    requestTypeCode:    replyFileMessageInput.requestTypeCode ?? generalTypeCode,
                                                                    requestUniqueId:    messageUniqueId)
            self.sendTextMessage(sendTextMessageInput: sendMessageParamModel, uniqueId: { _ in }, onSent: { (sent) in
                onSent(sent)
            }, onDelivere: { (delivered) in
                onDelivered(delivered)
            }) { (seen) in
                onSeen(seen)
            }
        }
        
    }
    
    
    
    // MARK: - Send Location Message
    
    /**
     SendLocationMessage:
     send user location StaticImage by getting user location detail
     
     by calling this function, a request will send to Map ServiceCall to get user StaticImage based on its location,
     then send a FileMessage with this StaticImage
     
     + Inputs:
     DeleteMessageRequestModel
     
     + Outputs:
     It has 2 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- completion:
     */
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
            let fileMessageInput = SendFileMessageRequestModel(fileName:        nil,
                                                               imageName:       sendLocationMessageRequest.sendMessageImageName,
                                                               xC:              sendLocationMessageRequest.sendMessageXC,
                                                               yC:              sendLocationMessageRequest.sendMessageYC,
                                                               hC:              sendLocationMessageRequest.sendMessageHC,
                                                               wC:              sendLocationMessageRequest.sendMessageWC,
                                                               threadId:        sendLocationMessageRequest.sendMessageThreadId,
                                                               content:         sendLocationMessageRequest.sendMessageContent,
                                                               metaData:        sendLocationMessageRequest.sendMessageMetaData,
                                                               repliedTo:       sendLocationMessageRequest.sendMessageRepliedTo,
                                                               fileToSend:      nil,
                                                               imageToSend:     (imageData as! Data),
                                                               requestTypeCode: sendLocationMessageRequest.requestTypeCode ?? self.generalTypeCode,
                                                               requestUniqueId: sendLocationMessageRequest.requestUniqueId ?? self.generateUUID())
            
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
    
    /**
     DeleteMessage:
     delete specific message by getting message id.
     
     By calling this function, a request of type 29 (DELETE_MESSAGE) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     DeleteMessageRequestModel
     
     + Outputs:
     It has 2 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- completion:
     */
    public func deleteMessage(deleteMessageInput:   DeleteMessageRequestModel,
                              uniqueId:             @escaping (String) -> (),
                              completion:           @escaping callbackTypeAlias) {
        log.verbose("Try to request to edit message with this parameters: \n \(deleteMessageInput)", context: "Chat")
        
        var content: JSON = []
        if let deleteForAll = deleteMessageInput.deleteForAll {
            content["deleteForAll"] = JSON("\(deleteForAll)")
        }
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.DELETE_MESSAGE.rawValue,
                                            content:            "\(content)",
                                            metaData:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          deleteMessageInput.subjectId,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           deleteMessageInput.requestTypeCode ?? generalTypeCode,
                                            uniqueId:           deleteMessageInput.requestUniqueId ?? generateUUID(),
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
    
    
    /**
    DeleteMultipleMessages:
    delete specific messages by getting their message ids.
    
    By calling this function, a request of type 29 (DELETE_MESSAGE) will send throut Chat-SDK,
    then the response will come back as callbacks to client whose calls this function.
    
    + Inputs:
    DeleteMultipleMessagesRequestModel
    
    + Outputs:
    It has 2 callbacks as response:
    1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
    2- completion:
    */
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
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.DELETE_MESSAGE.rawValue,
                                            content:            "\(content)",
                                            metaData:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          nil,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           deleteMessageInput.requestTypeCode ?? generalTypeCode,
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
    
    
    /**
    CancelSendMessage:
    cancel sending messages that has not been sent yet!
    
    By calling this function, we will delete the wait queue cache based on the request input
    
    + Inputs:
    DeleteMultipleMessagesRequestModel
    
    + Outputs:
    It has 1 callback as response:
    1- completion: the state of the response
    */
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
    
    /**
     MessageDeliveryList:
     list of participants that send deliver for some message id.
     
     By calling this function, a request of type 32 (GET_MESSAGE_DELEVERY_PARTICIPANTS) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     MessageDeliverySeenListRequestModel
     
     + Outputs:
     It has 2 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- completion:
     */
    public func messageDeliveryList(messageDeliveryListInput:   MessageDeliverySeenListRequestModel,
                                    uniqueId:                   @escaping (String) -> (),
                                    completion:                 @escaping callbackTypeAlias) {
        log.verbose("Try to request to get message deliver participants with this parameters: \n \(messageDeliveryListInput)", context: "Chat")
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.GET_MESSAGE_DELEVERY_PARTICIPANTS.rawValue,
                                            content:            "\(messageDeliveryListInput.convertContentToJSON())",
                                            metaData:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          nil,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           messageDeliveryListInput.requestTypeCode ?? generalTypeCode,
                                            uniqueId:           messageDeliveryListInput.requestUniqueId ?? generateUUID(),
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
    
    
    /**
     MessageSeenList:
     list of participants that send seen for some message id.
     
     By calling this function, a request of type 33 (GET_MESSAGE_SEEN_PARTICIPANTS) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     MessageDeliverySeenListRequestModel
     
     + Outputs:
     It has 2 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- completion:
     */
    public func messageSeenList(messageSeenListInput:   MessageDeliverySeenListRequestModel,
                                uniqueId:               @escaping (String) -> (),
                                completion:             @escaping callbackTypeAlias) {
        log.verbose("Try to request to get message seen participants with this parameters: \n \(messageSeenListInput)", context: "Chat")
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.GET_MESSAGE_SEEN_PARTICIPANTS.rawValue,
                                            content:            "\(messageSeenListInput.convertContentToJSON())",
                                            metaData:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          nil,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           messageSeenListInput.requestTypeCode ?? generalTypeCode,
                                            uniqueId:           messageSeenListInput.requestUniqueId ?? generateUUID(),
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
    
    /**
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
    public func startTyping(threadId:   Int,
                            uniqueId:   @escaping (String) -> ()) {
        
        let requestUniqueId = generateUUID()
        uniqueId(requestUniqueId)
        let signalMessageInput = SendSignalMessageRequestModel(signalType:      SignalMessageType.IS_TYPING,
                                                               threadId:        threadId,
                                                               requestUniqueId: requestUniqueId)
        
        // for every x seconds, call this function:
        isTypingArray.append(requestUniqueId)
        while (isTypingArray.count > 0) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                self.sendSignalMessage(input: signalMessageInput)
            }
        }
    }
    
    /**
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
    public func stopTyping(uniqueId: String) {
        for (index, item) in isTypingArray.enumerated() {
            if (item == uniqueId) {
                isTypingArray.remove(at: index)
                break
            }
        }
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
                                            metaData:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          input.threadId,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           nil,
                                            uniqueId:           input.requestUniqueId ?? generateUUID(),
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
