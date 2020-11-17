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
    
    // MARK: - Clear History
    /// ClearHistory:
    /// clear all messeages inside a specifi thread
    ///
    /// By calling this function, a request of type 44 (CLEAR_HISTORY) will send throut Chat-SDK,
    /// then the responses will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "ClearHistoryRequest" to this function
    ///
    /// Outputs:
    /// - It has 2 callbacks as responses
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (ClearHistoryRequest)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion: (response) it will returns the response that comes from server to this request. (Any as! ClearHistoryModel)
    public func clearHistory(inputModel clearHistoryInput: ClearHistoryRequest,
                             uniqueId:          @escaping ((String) -> ()),
                             completion:        @escaping callbackTypeAlias) {
          
        log.verbose("Try to request to create clear history with this parameters: \n \(clearHistoryInput)", context: "Chat")
        uniqueId(clearHistoryInput.uniqueId)
        clearHistoryCallbackToUser = completion
          
        let chatMessage = SendChatMessageVO(chatMessageVOType:  ChatMessageVOTypes.CLEAR_HISTORY.intValue(),
                                            content:            "\(clearHistoryInput.convertContentToJSON())",
                                            messageType:        nil,
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
         
      
    // MARK: - Delete Message
    
    /// DeleteMessage:
    /// delete specific message by getting message id.
    ///
    /// By calling this function, a request of type 29 (DELETE_MESSAGE) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "DeleteMessageRequest" to this function
    ///
    /// Outputs:
    /// - It has 2 callbacks as response:
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (DeleteMessageRequest)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion: (response) it will returns the response that comes from server to this request. (Any as! DeleteMessageModel)
    public func deleteMessage(inputModel deleteMessageInput:   DeleteMessageRequest,
                              uniqueId:             @escaping ((String) -> ()),
                              completion:           @escaping callbackTypeAlias) {
        
        log.verbose("Try to request to edit message with this parameters: \n \(deleteMessageInput)", context: "Chat")
        uniqueId(deleteMessageInput.uniqueId)
        
        deleteMessageCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  ChatMessageVOTypes.DELETE_MESSAGE.intValue(),
                                            content:            "\(deleteMessageInput.convertContentToJSON())",
                                            messageType:        nil,
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          deleteMessageInput.messageId,
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
    /// - you have to send your parameters as "DeleteMultipleMessagesRequest" to this function
    ///
    /// Outputs:
    /// - It has 2 callbacks as response:
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (DeleteMultipleMessagesRequest)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server.        (String)
    /// - parameter completion: (response) it will returns the response that comes from server to this request. (Any as! DeleteMessageModel)
    public func deleteMultipleMessages(inputModel deleteMessageInput:   DeleteMultipleMessagesRequest,
                                       uniqueIds:            @escaping (([String]) -> ()),
                                       completion:           @escaping callbackTypeAlias) {
        
        log.verbose("Try to request to edit message with this parameters: \n \(deleteMessageInput)", context: "Chat")
        uniqueIds(deleteMessageInput.uniqueIds)
        
        deleteMessageCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  ChatMessageVOTypes.DELETE_MESSAGE.intValue(),
                                            content:            "\(deleteMessageInput.convertContentToJSON())",
                                            messageType:        nil,
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
    
    
    // MARK: - Edit Message
    /// EditTextMessage:
    /// edit text of a messae.
    ///
    /// By calling this function, a request of type 28 (EDIT_MESSAGE) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "EditTextMessageRequest" to this function
    ///
    /// Outputs:
    /// - It has 2 callbacks as response:
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (EditTextMessageRequest)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion: (response) it will returns the response that comes from server to this request. (Any as! EditMessageModel)
    public func editMessage(inputModel editMessageInput:   EditTextMessageRequest,
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
            let messageObjectToSendToQueue = QueueOfWaitEditMessagesModel(textMessage:  editMessageInput.textMessage,
                                                                          messageType:  editMessageInput.messageType,
                                                                          metadata:     nil,
                                                                          repliedTo:    editMessageInput.repliedTo,
                                                                          messageId:    editMessageInput.messageId,
                                                                          threadId:     nil,
                                                                          typeCode:     editMessageInput.typeCode,
                                                                          uniqueId:     editMessageInput.uniqueId)
            Chat.cacheDB.saveEditMessageToWaitQueue(editMessage: messageObjectToSendToQueue)
        }
        
//        let messageTxtContent = editMessageInput.content
//        let messageTxtContent = MakeCustomTextToSend(message: editMessageInput.content).replaceSpaceEnterWithSpecificCharecters()
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  ChatMessageVOTypes.EDIT_MESSAGE.intValue(),
                                            content:            MakeCustomTextToSend(message: editMessageInput.textMessage).replaceSpaceEnterWithSpecificCharecters(),
                                            messageType:        editMessageInput.messageType.returnIntValue(),
                                            metadata:           nil,
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
        
    
    // MARK: - Forward Message
    /// ForwardTextMessage:
    /// forwar some messages to a thread.
    ///
    /// By calling this function, a request of type 22 (FORWARD_MESSAGE) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "ForwardMessageRequest" to this function
    ///
    /// Outputs:
    /// - It has 4 callbacks as response:
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (ForwardMessageRequest)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server.        (String)
    /// - parameter onSent:     (response) it will return this response if Sent Message comes from server, means that the message is sent successfully (Any as! SendMessageModel)
    /// - parameter onDelivere: (response) it will return this response if Deliver Message comes from server, means that the message is delivered to the destination (Any as! SendMessageModel)
    /// - parameter onSeen:     (response) it will return this response if Seen Message comes from server, means that the message is seen by the destination (Any as! SendMessageModel)
    public func forwardMessage(inputModel forwardMessageInput: ForwardMessageRequest,
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
                                                                                 metadata:      nil,
                                                                                 repliedTo:     nil,
                                                                                 threadId:      forwardMessageInput.threadId,
                                                                                 typeCode:      forwardMessageInput.typeCode,
                                                                                 uniqueId:      forwardMessageInput.uniqueIds[index])
                Chat.cacheDB.saveForwardMessageToWaitQueue(forwardMessage: messageObjectToSendToQueue)
            }
        }
        
        sendCallbackToUserOnSent = onSent
        sendCallbackToUserOnDeliver = onDelivere
        sendCallbackToUserOnSeen = onSeen
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  ChatMessageVOTypes.FORWARD_MESSAGE.intValue(),
                                            content:            "\(forwardMessageInput.messageIds)",
                                            messageType:        nil,
                                            metadata:           nil,
                                            repliedTo:          nil,
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
    
    
    
    // MARK: - Get History
    
    /// GetAllUnreadMessagesCount
    ///
    public func getAllUnreadMessagesCount(inputModel:       GetAllUnreadMessageCountRequest,
                                          getCacheResponse: Bool?,
                                          uniqueId:         @escaping ((String) -> ()),
                                          completion:       @escaping callbackTypeAlias,
                                          cacheResponse:    @escaping ((UnreadMessageCountModel) -> ())) {
        
        log.verbose("Try to request to get all unread messages count", context: "Chat")
        uniqueId(inputModel.uniqueId)
        getAllUnreadMessagesCountCallbackToUser = completion
      
        let chatMessage = SendChatMessageVO(chatMessageVOType:  ChatMessageVOTypes.ALL_UNREAD_MESSAGE_COUNT.intValue(),
                                            content:            "\(inputModel.convertContentToJSON())",
                                            messageType:        nil,
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          nil,
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
                                callbacks:          [(GetAllUnreadMessagesCountCallbacks(), inputModel.uniqueId)],
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil)
      
        if (getCacheResponse ?? enableCache) {
            let cacheUnreadCount = Chat.cacheDB.retrieveAllUnreadMessageCount()
            let unreadMessageCountModel = UnreadMessageCountModel(unreadCount:  cacheUnreadCount,
                                                                  hasError:     false,
                                                                  errorMessage: "",
                                                                  errorCode:    0)
            cacheResponse(unreadMessageCountModel)
        }
    }
    
    /// GetHistory:
    /// get messages in a specific thread
    ///
    /// By calling this function, a request of type 15 (GET_HISTORY) will send throut Chat-SDK,
    /// then the responses will come back as callbacks to the client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "GetHistoryRequest" to this function
    ///
    /// Outputs:
    /// - It has 9 callbacks as responses
    ///
    /// - parameter inputModel:             (input) you have to send your parameters insid this model. (GetHistoryRequest)
    /// - parameter getCacheResponse:       (input) specify if you want to get cache response for this request (Bool?)
    /// - parameter uniqueId:               (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion:             (response) it will returns the response that comes from server to this request. (Any as! GetHistoryModel)
    /// - parameter cacheResponse:          (response) there is another response that comes from CacheDB to the user, if user has set 'enableCache' vaiable to be true. (GetHistoryModel)
    /// - parameter textMessagesNotSent:    (response) it will returns the Test Messages that has not been Sent yet! ([QueueOfWaitTextMessagesModel])
    /// - parameter editMessagesNotSent:    (response) it will returns the Edit Messages requests that has not been Sent yet! ([QueueOfWaitEditMessagesModel])
    /// - parameter forwardMessagesNotSent: (response) it will returns the Forward Messages requests that has not been Sent yet! ([QueueOfWaitForwardMessagesModel])
    /// - parameter fileMessagesNotSent:    (response) it will returns the File Messages requests that has not been Sent yet! ([QueueOfWaitFileMessagesModel])
    /// - parameter uploadImageNotSent:     (response) it will returns the Upload Image requests that has not been Sent yet! ([QueueOfWaitUploadImagesModel])
    /// - parameter uploadFileNotSent:      (response) it will returns the Upload File requests that has not been Sent yet! ([QueueOfWaitUploadFilesModel])
    public func getHistory(inputModel getHistoryInput:  GetHistoryRequest,
                           getCacheResponse:            Bool?,
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
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  ChatMessageVOTypes.GET_HISTORY.intValue(),
                                            content:            "\(getHistoryInput.convertContentToJSON())",
                                            messageType:        nil,
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
        if (getCacheResponse ?? enableCache) {
            
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
                                                                            messageType:    getHistoryInput.messageType,
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
    /// - you have to send your parameters as "GetMentionedRequest" to this function
    ///
    /// Outputs:
    /// - It has 3 callbacks as responses
    ///
    /// - parameter inputModel:         (input) you have to send your parameters insid this model. (GetMentionedRequest)
    /// - parameter getCacheResponse:   (input) specify if you want to get cache response for this request (Bool?)
    /// - parameter uniqueId:           (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion:         (response) it will returns the response that comes from server to this request. (Any as! GetHistoryModel)
    /// - parameter cacheResponse:      (response) there is another response that comes from CacheDB to the user, if user has set 'enableCache' vaiable to be true. (GetHistoryModel)
    public func getMentionList(inputModel getMentionInput:  GetMentionedRequest,
                               getCacheResponse:            Bool?,
                               uniqueId:                @escaping ((String) -> ()),
                               completion:              @escaping callbackTypeAlias,
                               cacheResponse:           @escaping ((GetHistoryModel) -> ())) {
        log.verbose("Try to request to get mention list with this parameters: \n \(getMentionInput)", context: "Chat")
        uniqueId(getMentionInput.uniqueId)
        getMentionListCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  ChatMessageVOTypes.GET_HISTORY.intValue(),
                                            content:            "\(getMentionInput.convertContentToJSON())",
                                            messageType:        nil,
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
        
        if (getCacheResponse ?? enableCache) {
            // ToDo:
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
    /// - you have to send your parameters as "GetMessageDeliveredSeenListRequest" to this function
    ///
    /// Outputs:
    /// - It has 2 callbacks as response:
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (GetMessageDeliveredSeenListRequest)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion: (response) it will returns the response that comes from server to this request. (Any as! GetMessageDeliverList)
    public func messageDeliveryList(inputModel messageDeliveryListInput:   GetMessageDeliveredSeenListRequest,
                                    uniqueId:                   @escaping ((String) -> ()),
                                    completion:                 @escaping callbackTypeAlias) {
        
        log.verbose("Try to request to get message deliver participants with this parameters: \n \(messageDeliveryListInput)", context: "Chat")
        uniqueId(messageDeliveryListInput.uniqueId)
        
        getMessageDeliverListCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  ChatMessageVOTypes.GET_MESSAGE_DELEVERY_PARTICIPANTS.intValue(),
                                            content:            "\(messageDeliveryListInput.convertContentToJSON())",
                                            messageType:        nil,
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
    /// - you have to send your parameters as "GetMessageDeliveredSeenListRequest" to this function
    ///
    /// Outputs:
    /// - It has 2 callbacks as response:
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (GetMessageDeliveredSeenListRequest)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion: (response) it will returns the response that comes from server to this request. (Any as! GetMessageSeenList)
    public func messageSeenList(inputModel messageSeenListInput:   GetMessageDeliveredSeenListRequest,
                                uniqueId:               @escaping ((String) -> ()),
                                completion:             @escaping callbackTypeAlias) {
        
        log.verbose("Try to request to get message seen participants with this parameters: \n \(messageSeenListInput)", context: "Chat")
        uniqueId(messageSeenListInput.uniqueId)
        
        getMessageSeenListCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  ChatMessageVOTypes.GET_MESSAGE_SEEN_PARTICIPANTS.intValue(),
                                            content:            "\(messageSeenListInput.convertContentToJSON())",
                                            messageType:        nil,
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
    
    
    
    // MARK: - Pin/Unpin Message
    
    /// PinMessage:
    /// pin message on a specific thread
    ///
    /// by calling this method, message of type "PIN_MESSAGE" is sends to the sserver
    ///
    /// Inputs:
    /// - you have to send your parameters as "PinUnpinMessageRequest" to this function
    ///
    /// Outputs:
    /// - It has 2 callbacks as response:
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (PinUnpinMessageRequest)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion: (response) it will returns the response that comes from server to this request. (Any as! PinUnpinMessageModel)
    public func pinMessage(inputModel:  PinUnpinMessageRequest,
                           uniqueId:    @escaping (String) -> (),
                           completion:  @escaping callbackTypeAlias) {
            
        log.verbose("Try to request to pin message with this parameters: \n \(inputModel)", context: "Chat")
        uniqueId(inputModel.uniqueId)
        
        pinMessageCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  ChatMessageVOTypes.PIN_MESSAGE.intValue(),
                                            content:            "\(inputModel.convertContentToJSON())",
                                            messageType:        nil,
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
    /// unpin the message from a specific thread
    ///
    /// by calling this method, message of type "UNPIN_MESSAGE" is sends to the sserver
    ///
    /// Inputs:
    /// - you have to send your parameters as "PinUnpinMessageRequest" to this function
    ///
    /// Outputs:
    /// - It has 2 callbacks as response:
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (PinUnpinMessageRequest)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion: (response) it will returns the response that comes from server to this request. (Any as! PinUnpinMessageModel)
    public func unpinMessage(inputModel:  PinUnpinMessageRequest,
                             uniqueId:    @escaping (String) -> (),
                             completion:  @escaping callbackTypeAlias) {
            
        log.verbose("Try to request to unpin message with this parameters: \n \(inputModel)", context: "Chat")
        uniqueId(inputModel.uniqueId)
        
        unpinMessageCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  ChatMessageVOTypes.UNPIN_MESSAGE.intValue(),
                                            content:            "\(inputModel.convertContentToJSON())",
                                            messageType:        nil,
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
    
    
    // MARK: - Reply Text Message
    /// ReplyTextMessage:
    /// send reply message to a messsage.
    ///
    /// By calling this function, a request of type 2 (FORWARD_MESSAGE) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "ReplyTextMessageRequest" to this function
    ///
    /// Outputs:
    /// - It has 4 callbacks as response:
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (ReplyTextMessageRequest)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter onSent:     (response) it will return this response if Sent Message comes from server, means that the message is sent successfully (Any as! SendMessageModel)
    /// - parameter onDelivere: (response) it will return this response if Deliver Message comes from server, means that the message is delivered to the destination (Any as! SendMessageModel)
    /// - parameter onSeen:     (response) it will return this response if Seen Message comes from server, means that the message is seen by the destination (Any as! SendMessageModel)
    public func replyMessage(inputModel replyMessageInput: ReplyTextMessageRequest,
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
            let messageObjectToSendToQueue = QueueOfWaitTextMessagesModel(textMessage:      replyMessageInput.textMessage,
                                                                          messageType:      replyMessageInput.messageType,
                                                                          metadata:         (replyMessageInput.metadata != nil) ? "\(replyMessageInput.metadata!)" : nil,
                                                                          repliedTo:        replyMessageInput.repliedTo,
                                                                          systemMetadata:   nil,
                                                                          threadId:         replyMessageInput.threadId,
                                                                          typeCode:         replyMessageInput.typeCode,
                                                                          uniqueId:         replyMessageInput.uniqueId)
            Chat.cacheDB.saveTextMessageToWaitQueue(textMessage: messageObjectToSendToQueue)
        }
        
//        let messageTxtContent = replyMessageInput.content
//        let messageTxtContent = MakeCustomTextToSend(message: replyMessageInput.content).replaceSpaceEnterWithSpecificCharecters()
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  ChatMessageVOTypes.MESSAGE.intValue(),
                                            content:            MakeCustomTextToSend(message: replyMessageInput.textMessage).replaceSpaceEnterWithSpecificCharecters(),
                                            messageType:        replyMessageInput.messageType.returnIntValue(),
                                            metadata:           (replyMessageInput.metadata != nil) ? "\(MakeCustomTextToSend(message: replyMessageInput.metadata!).replaceSpaceEnterWithSpecificCharecters())" : nil,
                                            repliedTo:          replyMessageInput.repliedTo,
                                            systemMetadata:     nil,
                                            subjectId:          replyMessageInput.threadId,
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
        
    
    // MARK: - Send Deliver/Seen Message
    
    /// Deliver:
    /// send deliver for some message.
    ///
    /// By calling this function, a request of type 4 (DELIVERY) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "SendDeliverSeenRequest" to this function
    ///
    /// Outputs:
    /// - this method does not have any output
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (SendDeliverSeenRequest)
    public func deliver(inputModel deliverInput: SendDeliverSeenRequest) {
        
        log.verbose("Try to send deliver message for a message id with this parameters: \n messageId = \(deliverInput.messageId) , ownerId = \(deliverInput.ownerId)", context: "Chat")
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  ChatMessageVOTypes.DELIVERY.intValue(),
                                            content:            "\(deliverInput.messageId)",
                                            messageType:        nil,
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          nil,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           deliverInput.typeCode ?? generalTypeCode,
                                            uniqueId:           nil,
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: nil)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  3)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callbacks:          nil,
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil)
    }
    
    
    /// Seen:
    /// send seen for some message.
    ///
    /// By calling this function, a request of type 5 (SEEN) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "SendDeliverSeenRequest" to this function
    ///
    /// Outputs:
    /// - this method does not have any output
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (SendDeliverSeenRequest)
    public func seen(inputModel seenInput: SendDeliverSeenRequest) {
        
        log.verbose("Try to send seen message for a message id with this parameters: \n messageId = \(seenInput.messageId) , ownerId = \(seenInput.ownerId)", context: "Chat")
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  ChatMessageVOTypes.SEEN.intValue(),
                                            content:            "\(seenInput.messageId)",
                                            messageType:        nil,
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          nil,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           seenInput.typeCode ?? generalTypeCode,
                                            uniqueId:           nil,
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: nil)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  3)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callbacks:          nil,
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil)
    }
    
    
    
    // MARK: - Send Interactive Message
    /// SendInteractiveMessage:
    /// send a botMessage.
    ///
    /// By calling this function, a request of type 40 (BOT_MESSAGE) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "SendInteractiveMessageRequest" to this function
    ///
    /// Outputs:
    /// - It has 4 callbacks as response:
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (SendInteractiveMessageRequest)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter onSent:     (response) it will return this response if Sent Message comes from server, means that the message is sent successfully (Any as! SendMessageModel)
    /// - parameter onDelivere: (response) it will return this response if Deliver Message comes from server, means that the message is delivered to the destination (Any as! SendMessageModel)
    /// - parameter onSeen:     (response) it will return this response if Seen Message comes from server, means that the message is seen by the destination (Any as! SendMessageModel)
    public func sendInteractiveMessage(inputModel sendInterActiveMessageInput:  SendInteractiveMessageRequest,
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
//        let messageTxtContent = MakeCustomTextToSend(message: sendInterActiveMessageInput.content).replaceSpaceEnterWithSpecificCharecters()
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  ChatMessageVOTypes.BOT_MESSAGE.intValue(),
                                            content:            MakeCustomTextToSend(message: sendInterActiveMessageInput.textMessage).replaceSpaceEnterWithSpecificCharecters(),
                                            messageType:        nil,
                                            metadata:           "\(MakeCustomTextToSend(message: sendInterActiveMessageInput.metadata).replaceSpaceEnterWithSpecificCharecters())",
                                            repliedTo:          nil,
                                            systemMetadata:     (sendInterActiveMessageInput.systemMetadata != nil) ? "\(MakeCustomTextToSend(message: sendInterActiveMessageInput.systemMetadata!).replaceSpaceEnterWithSpecificCharecters())" : nil,
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
        
        
    // MARK: - Send Location Message
    
    /// SendLocationMessage:
    /// send user location StaticImage by getting user location detail
    ///
    /// by calling this function, a request will send to Map ServiceCall to get user StaticImage based on its location,
    /// then send a FileMessage with this StaticImage
    ///
    /// Inputs:
    /// - you have to send your parameters as "SendLocationMessageRequest" to this function
    ///
    /// Outputs:
    /// - It has 6 callbacks as response:
    ///
    /// - parameter inputModel:         (input) you have to send your parameters insid this model. (SendLocationMessageRequest)
    /// - parameter uniqueId:           (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter downloadProgress:   (response)  it will returns the progress of the downloading image from MapServices by a value between 0 and 1. (Float)
    /// - parameter uploadProgress:     (response)  it will returns the progress of the uploading image by a value between 0 and 1. (Float)
    /// - parameter onSent:             (response) it will return this response if Sent Message comes from server, means that the message is sent successfully (Any as! SendMessageModel)
    /// - parameter onDelivere:         (response) it will return this response if Deliver Message comes from server, means that the message is delivered to the destination (Any as! SendMessageModel)
    /// - parameter onSeen:             (response) it will return this response if Seen Message comes from server, means that the message is seen by the destination (Any as! SendMessageModel)
    public func sendLocationMessage(inputModel sendLocationMessageRequest: SendLocationMessageRequest,
                                    downloadProgress:           @escaping ((Float) -> ()),
                                    uploadUniqueId:             @escaping ((String) -> ()),
                                    uploadProgress:             @escaping ((Float) -> ()),
                                    messageUniqueId:            @escaping ((String) -> ()),
                                    onSent:                     @escaping callbackTypeAlias,
                                    onDelivere:                 @escaping callbackTypeAlias,
                                    onSeen:                     @escaping callbackTypeAlias) {
        
        let mapStaticImageInput = MapStaticImageRequestModel(centerLat: sendLocationMessageRequest.mapCenter.lat,
                                                             centerLng: sendLocationMessageRequest.mapCenter.lng,
                                                             height:    sendLocationMessageRequest.mapHeight,
                                                             type:      sendLocationMessageRequest.mapType,
                                                             width:     sendLocationMessageRequest.mapWidth,
                                                             zoom:      sendLocationMessageRequest.mapZoom)
        
        mapStaticImage(inputModel: mapStaticImageInput,
                       uniqueId: { _ in },
                       progress: { (myProgress) in
            downloadProgress(myProgress)
        }) { (imageData) in
            
            let uploadInput = UploadImageRequest(dataToSend:        (imageData as! Data),
                                                 fileExtension:     ".png",
                                                 fileName:          sendLocationMessageRequest.mapImageName,
                                                 mimeType:          "image/png",
                                                 originalName:      nil,
                                                 xC:                nil,
                                                 yC:                nil,
                                                 hC:                nil,
                                                 wC:                nil,
                                                 userGroupHash:     sendLocationMessageRequest.userGroupHash,
                                                 typeCode:          sendLocationMessageRequest.typeCode ?? self.generalTypeCode,
                                                 uniqueId:          sendLocationMessageRequest.uniqueId)
            
            let messageInput = SendTextMessageRequestModel(content:         sendLocationMessageRequest.textMessage ?? "",
                                                           messageType:     MessageType.PICTURE,
                                                           metadata:        nil,
                                                           repliedTo:       sendLocationMessageRequest.repliedTo,
                                                           systemMetadata:  sendLocationMessageRequest.systemMetadata,
                                                           threadId:        sendLocationMessageRequest.threadId,
                                                           typeCode:        sendLocationMessageRequest.typeCode ?? self.generalTypeCode,
                                                           uniqueId:        sendLocationMessageRequest.uniqueId)
            
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
    
    
    // MARK: - Send/Reply File Message
    
    /// SendFileMessage:
    /// send some file and also send some message too with it.
    ///
    /// By calling this function, first an HTTP request of type (GET_IMAGE or GET_FILE), and then send message request of type 2 (MESSAGE) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "SendReplyFileMessageRequest" to this function
    ///
    /// Outputs:
    /// - It has 5 callbacks as response:
    ///
    /// - parameter inputModel:     (input) you have to send your parameters insid this model. (SendReplyFileMessageRequest)
    /// - parameter uniqueId:       (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter uploadProgress: (response)  it will returns the progress of the uploading request by a value between 0 and 1. (Float)
    /// - parameter onSent:         (response) it will return this response if Sent Message comes from server, means that the message is sent successfully (Any as! SendMessageModel)
    /// - parameter onDelivere:     (response) it will return this response if Deliver Message comes from server, means that the message is delivered to the destination (Any as! SendMessageModel)
    /// - parameter onSeen:         (response) it will return this response if Seen Message comes from server, means that the message is seen by the destination (Any as! SendMessageModel)
    public func sendFileMessage(inputModel sendFileMessageInput:   SendReplyFileMessageRequest,
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
                let messageObjectToSendToQueue = QueueOfWaitFileMessagesModel(textMessage:  sendFileMessageInput.messageInput.textMessage,
                                                                              messageType:  sendFileMessageInput.messageInput.messageType,
                                                                              fileExtension:    file.fileExtension,
                                                                              fileName:         file.fileName,
                                                                              isPublic:         file.isPublic,
                                                                              metadata:     (sendFileMessageInput.messageInput.metadata != nil) ? "\(sendFileMessageInput.messageInput.metadata!)" : nil,
                                                                              mimeType:         file.mimeType,
                                                                              originalName:     file.originalName,
                                                                              repliedTo:    sendFileMessageInput.messageInput.repliedTo,
                                                                              threadId:     sendFileMessageInput.messageInput.threadId,
                                                                              userGroupHash:    file.userGroupHash,
                                                                              xC:               nil,
                                                                              yC:               nil,
                                                                              hC:               nil,
                                                                              wC:               nil,
                                                                              fileToSend:       file.dataToSend,
                                                                              imageToSend:      nil,
                                                                              typeCode:     sendFileMessageInput.messageInput.typeCode,
                                                                              uniqueId:     sendFileMessageInput.messageInput.uniqueId)
                Chat.cacheDB.saveFileMessageToWaitQueue(fileMessage: messageObjectToSendToQueue)
                
            } else if let image = sendFileMessageInput.uploadInput as? UploadImageRequest {
                let messageObjectToSendToQueue = QueueOfWaitFileMessagesModel(textMessage:  sendFileMessageInput.messageInput.textMessage,
                                                                              messageType:  sendFileMessageInput.messageInput.messageType,
                                                                              fileExtension:    image.fileExtension,
                                                                              fileName:         image.fileName,
                                                                              isPublic:         image.isPublic,
                                                                              metadata:     (sendFileMessageInput.messageInput.metadata != nil) ? "\(sendFileMessageInput.messageInput.metadata!)" : nil,
                                                                              mimeType:         image.mimeType,
                                                                              originalName:     image.originalName,
                                                                              repliedTo:    sendFileMessageInput.messageInput.repliedTo,
                                                                              threadId:     sendFileMessageInput.messageInput.threadId,
                                                                              userGroupHash:    image.userGroupHash,
                                                                              xC:               image.xC,
                                                                              yC:               image.yC,
                                                                              hC:               image.hC,
                                                                              wC:               image.wC,
                                                                              fileToSend:       nil,
                                                                              imageToSend:      image.dataToSend,
                                                                              typeCode:     sendFileMessageInput.messageInput.typeCode,
                                                                              uniqueId:     sendFileMessageInput.messageInput.uniqueId)
                Chat.cacheDB.saveFileMessageToWaitQueue(fileMessage: messageObjectToSendToQueue)
            }
            
        }
        
        var metadata: JSON = [:]
        
        if let image = sendFileMessageInput.uploadInput as? UploadImageRequest {
            let uploadRequest: UploadImageRequest!
            if let userGroupHash = image.userGroupHash {
                uploadRequest = UploadImageRequest(dataToSend:      image.dataToSend,
                                                   fileExtension:   image.fileExtension,
                                                   fileName:        image.fileName,
                                                   mimeType:        image.mimeType,
                                                   originalName:    image.originalName,
                                                   xC:              image.xC,
                                                   yC:              image.yC,
                                                   hC:              image.hC,
                                                   wC:              image.wC,
                                                   userGroupHash:   userGroupHash,
                                                   typeCode:        image.typeCode,
                                                   uniqueId:        image.uniqueId)
            } else {
                uploadRequest = UploadImageRequest(dataToSend:      image.dataToSend,
                                                   fileExtension:   image.fileExtension,
                                                   fileName:        image.fileName,
                                                   isPublic:        true,
                                                   mimeType:        image.mimeType,
                                                   originalName:    image.originalName,
                                                   xC:              image.xC,
                                                   yC:              image.yC,
                                                   hC:              image.hC,
                                                   wC:              image.wC,
                                                   typeCode:        image.typeCode,
                                                   uniqueId:        image.uniqueId)
            }
            
            uploadImage(inputModel: uploadRequest, uniqueId: { _ in }, progress: { (progress) in
                uploadProgress(progress)
            }) { (response) in
                let myResponse: UploadImageResponse = response as! UploadImageResponse
                if !(myResponse.hasError) {
                    metadata["file"] = myResponse.returnMetaData(onServiceAddress: self.SERVICE_ADDRESSES.FILESERVER_ADDRESS)
                    metadata["file"]["actualHeight"] = JSON(image.hC)
                    metadata["file"]["actualWidth"]  = JSON(image.wC)
                    metadata["file"]["extension"]   = JSON(uploadRequest.fileExtension ?? "")
                    metadata["file"]["link"]        = JSON("\(self.SERVICE_ADDRESSES.PODSPACE_FILESERVER_ADDRESS)\(SERVICES_PATH.DRIVE_DOWNLOAD_IMAGE.stringValue())?hash=\(myResponse.uploadImage?.hashCode ?? "")")
                    metadata["file"]["mimeType"]    = JSON(uploadRequest.mimeType)
                    metadata["file"]["name"]        = JSON(uploadRequest.fileName)
                    metadata["file"]["originalName"] = JSON(uploadRequest.originalName)
                    metadata["file"]["size"]        = JSON(uploadRequest.fileSize)
                    metadata["fileHash"]            = JSON(myResponse.uploadImage?.hashCode ?? "")
                    metadata["name"]                = JSON(myResponse.uploadImage?.name ?? "")
                    metadata["id"]                  = JSON(0)
                    sendMessage(withMetadata: metadata, messageType: MessageType.POD_SPACE_PICTURE)
                } else {
                    self.delegate?.chatError(errorCode:     myResponse.errorCode,
                                             errorMessage:  myResponse.errorMessage,
                                             errorResult:   nil)
                    return
                }
            }
            
        } else if let file = sendFileMessageInput.uploadInput as? UploadFileRequest {
            let uploadRequest: UploadFileRequest!
            if let userGroupHash = file.userGroupHash {
                uploadRequest = UploadFileRequest(dataToSend:       file.dataToSend,
                                                  fileExtension:    file.fileExtension,
                                                  fileName:         file.fileName,
                                                  mimeType:         file.mimeType,
                                                  originalName:     file.originalName,
                                                  userGroupHash:    userGroupHash,
                                                  typeCode:         file.typeCode,
                                                  uniqueId:         file.uniqueId)
            } else {
                uploadRequest = UploadFileRequest(dataToSend:       file.dataToSend,
                                                  fileExtension:    file.fileExtension,
                                                  fileName:         file.fileName,
                                                  isPublic:         true,
                                                  mimeType:         file.mimeType,
                                                  originalName:     file.originalName,
                                                  typeCode:         file.typeCode,
                                                  uniqueId:         file.uniqueId)
            }
            
            uploadFile(inputModel: uploadRequest, uniqueId: { _ in }, progress: { (progress) in
                uploadProgress(progress)
            }) { (response) in
                let myResponse: UploadFileResponse = response as! UploadFileResponse
                if !(myResponse.hasError) {
                    metadata["file"]    = myResponse.returnMetaData(onServiceAddress: self.SERVICE_ADDRESSES.FILESERVER_ADDRESS)
                    metadata["file"]["extension"]   = JSON(uploadRequest.fileExtension ?? "")
                    metadata["file"]["link"]        = JSON("\(self.SERVICE_ADDRESSES.PODSPACE_FILESERVER_ADDRESS)\(SERVICES_PATH.DRIVE_DOWNLOAD_FILE.stringValue())?hash=\(myResponse.uploadFile?.hashCode ?? "")")
                    metadata["file"]["mimeType"]    = JSON(uploadRequest.mimeType)
                    metadata["file"]["name"]        = JSON(uploadRequest.fileName)
                    metadata["file"]["originalName"] = JSON(uploadRequest.originalName)
                    metadata["file"]["size"]        = JSON(uploadRequest.fileSize)
                    metadata["fileHash"]            = JSON(myResponse.uploadFile?.hashCode ?? "")
                    metadata["name"]                = JSON(myResponse.uploadFile?.name ?? "")
                    metadata["id"]                  = JSON(0)
                    sendMessage(withMetadata: metadata, messageType: MessageType.POD_SPACE_FILE)
                } else {
                    self.delegate?.chatError(errorCode:     myResponse.errorCode,
                                             errorMessage:  myResponse.errorMessage,
                                             errorResult:   nil)
                    return
                }
                
            }
            
        }
        
        // this will call when all data were uploaded and it will sends the textMessage
        func sendMessage(withMetadata: JSON, messageType: MessageType) {
            let sendMessageParamModel = SendTextMessageRequestModel(content:        sendFileMessageInput.messageInput.textMessage,
                                                                    messageType:    messageType,
                                                                    metadata:       "\(withMetadata)",
                                                                    repliedTo:      sendFileMessageInput.messageInput.repliedTo,
                                                                    systemMetadata: sendFileMessageInput.messageInput.systemMetadata,
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
    /// - you have to send your parameters as "SendReplyFileMessageRequest" to this function
    ///
    /// Outputs:
    /// - It has 5 callbacks as response:
    ///
    /// - parameter inputModel:     (input) you have to send your parameters insid this model. (SendReplyFileMessageRequest)
    /// - parameter uniqueId:       (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter uploadProgress: (response) it will returns the progress of the uploading request by a value between 0 and 1. (Float)
    /// - parameter onSent:         (response) it will return this response if Sent Message comes from server, means that the message is sent successfully (Any as! SendMessageModel)
    /// - parameter onDelivere:     (response) it will return this response if Deliver Message comes from server, means that the message is delivered to the destination (Any as! SendMessageModel)
    /// - parameter onSeen:         (response) it will return this response if Seen Message comes from server, means that the message is seen by the destination (Any as! SendMessageModel)
    public func replyFileMessage(inputModel replyFileMessageInput: SendReplyFileMessageRequest,
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
    
    
    
    // MARK: - Send Text Message
        
    /// SendTextMessage:
    /// send a text to somebody.
    ///
    /// By calling this function, a request of type 2 (MESSAGE) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "SendTextMessageRequest" to this function
    ///
    /// Outputs:
    /// - It has 4 callbacks as response:
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (SendTextMessageRequest)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter onSent:     (response) it will return this response if Sent Message comes from server, means that the message is sent successfully (Any as! SendMessageModel)
    /// - parameter onDelivere: (response) it will return this response if Deliver Message comes from server, means that the message is delivered to the destination (Any as! SendMessageModel)
    /// - parameter onSeen:     (response) it will return this response if Seen Message comes from server, means that the message is seen by the destination (Any as! SendMessageModel)
    public func sendTextMessage(inputModel sendTextMessageInput:    SendTextMessageRequest,
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
            let messageObjectToSendToQueue = QueueOfWaitTextMessagesModel(textMessage:      sendTextMessageInput.textMessage,
                                                                          messageType:      sendTextMessageInput.messageType,
                                                                          metadata:         (sendTextMessageInput.metadata != nil) ? "\(sendTextMessageInput.metadata!)" : nil,
                                                                          repliedTo:        sendTextMessageInput.repliedTo,
                                                                          systemMetadata:   (sendTextMessageInput.systemMetadata != nil) ? "\(sendTextMessageInput.systemMetadata!)" : nil,
                                                                          threadId:         sendTextMessageInput.threadId,
                                                                          typeCode:         sendTextMessageInput.typeCode,
                                                                          uniqueId:         sendTextMessageInput.uniqueId)
            Chat.cacheDB.saveTextMessageToWaitQueue(textMessage: messageObjectToSendToQueue)
        }
        
//        let messageTxtContent = sendTextMessageInput.content
//        let messageTxtContent = MakeCustomTextToSend(message: sendTextMessageInput.content).replaceSpaceEnterWithSpecificCharecters()
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  ChatMessageVOTypes.MESSAGE.intValue(),
                                            content:            MakeCustomTextToSend(message: sendTextMessageInput.textMessage).replaceSpaceEnterWithSpecificCharecters(),
                                            messageType:        sendTextMessageInput.messageType.returnIntValue(),
                                            metadata:           (sendTextMessageInput.metadata != nil) ? "\(MakeCustomTextToSend(message: sendTextMessageInput.metadata!).replaceSpaceEnterWithSpecificCharecters())" : nil,
                                            repliedTo:          sendTextMessageInput.repliedTo,
                                            systemMetadata:     (sendTextMessageInput.systemMetadata != nil) ? "\(MakeCustomTextToSend(message: sendTextMessageInput.systemMetadata!).replaceSpaceEnterWithSpecificCharecters())" : nil,
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
    public func startTyping(threadId:   Int) {
        
        let t = RepeatingTimer(timeInterval: 2.0)
        sendIsTypingMessageTimer = (t, threadId)
        
//        isTypingOnThread = threadId
//        repeatTimer?.fire()
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
//        if isTypingOnThread != 0 {
//            let systemEventModel = SystemEventModel(type: SystemEventTypes.STOP_TYPING, time: nil, threadId: isTypingOnThread, user: nil)
//            delegate?.systemEvents(model: systemEventModel)
//        }
//        isTypingOnThread = 0
//        repeatTimer?.invalidate()
//        repeatTimer = nil
        
        
        sendIsTypingMessageTimer = nil
        
    }
    
    
    /**
     * send Signal Message:
     *
     *  calling this method, will start to send SignalMessage to the server
     *
     *  + Access:   Private
     *  + Inputs:   SendSignalMessageRequest
     *  + Outputs:  _
     *
     */
    func sendSignalMessage(input: SendSignalMessageRequest) {
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  ChatMessageVOTypes.SYSTEM_MESSAGE.intValue(),
                                            content:            "\(input.convertContentToJSON())",
                                            messageType:        nil,
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
        
    
    
    
    
    
    // MARK: - Cancle Message
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
    
    
    
    
    
    
    
    
    // MARK: Resend/Remove Queue Methods
    
    public func resend(textMessages:    [QueueOfWaitTextMessagesModel],
                       uniqueId:        @escaping (String)->(),
                       sent:            @escaping (SendMessageModel)->(),
                       deliver:         @escaping (SendMessageModel)->(),
                       seen:            @escaping (SendMessageModel)->() ) {
        
        for txt in textMessages {
            let input = SendTextMessageRequest(messageType:     txt.messageType,
                                               metadata:        txt.metadata,
                                               repliedTo:       txt.repliedTo,
                                               systemMetadata:  txt.systemMetadata,
                                               textMessage:     txt.textMessage!,
                                               threadId:        txt.threadId!,
                                               typeCode:        txt.typeCode,
                                               uniqueId:        txt.uniqueId)
            
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
            let input = EditTextMessageRequest(messageType: editMsg.messageType,
                                               repliedTo:   editMsg.repliedTo,
                                               messageId:   editMsg.messageId!,
                                               textMessage: editMsg.textMessage!,
                                               typeCode:    editMsg.typeCode,
                                               uniqueId:    editMsg.uniqueId)
                                                    
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
            let input = ForwardMessageRequest(messageIds:   [frwrdMsg.messageId!],
                                              metadata:     frwrdMsg.metadata,
                                              repliedTo:    frwrdMsg.repliedTo,
                                              threadId:     frwrdMsg.threadId!,
                                              typeCode:     frwrdMsg.typeCode)
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
        
        let message = SendTextMessageRequest(messageType:       MessageType.FILE,
                                             metadata:          fileMessages.metadata,
                                             repliedTo:         fileMessages.repliedTo,
                                             systemMetadata:    nil,
                                             textMessage:       fileMessages.textMessage ?? "",
                                             threadId:          fileMessages.threadId!,
                                             typeCode:          fileMessages.typeCode,
                                             uniqueId:          fileMessages.uniqueId)
        
        var upload: UploadRequest? = nil
        if let fileData = fileMessages.fileToSend {
            let input: UploadFileRequest!
            if let userGroupHash = fileMessages.userGroupHash {
                input = UploadFileRequest(dataToSend:       fileData,
                                          fileExtension:    fileMessages.fileExtension,
                                          fileName:         fileMessages.fileName,
                                          mimeType:         fileMessages.mimeType,
                                          originalName:     fileMessages.originalName,
                                          userGroupHash:    userGroupHash,
                                          typeCode:         fileMessages.typeCode,
                                          uniqueId:         fileMessages.uniqueId)
            } else {
                input = UploadFileRequest(dataToSend:       fileData,
                                          fileExtension:    fileMessages.fileExtension,
                                          fileName:         fileMessages.fileName,
                                          isPublic:         true,
                                          mimeType:         fileMessages.mimeType,
                                          originalName:     fileMessages.originalName,
                                          typeCode:         fileMessages.typeCode,
                                          uniqueId:         fileMessages.uniqueId)
            }
            upload = input
            
        } else if let imageData = fileMessages.imageToSend {
            let input: UploadImageRequest!
            if let userGroupHash = fileMessages.userGroupHash {
                input = UploadImageRequest(dataToSend:      imageData,
                                           fileExtension:   fileMessages.fileExtension,
                                           fileName:        fileMessages.fileName,
                                           mimeType:        fileMessages.mimeType,
                                           originalName:     fileMessages.originalName,
                                           xC:              fileMessages.xC ?? 0,
                                           yC:              fileMessages.yC ?? 0,
                                           hC:              fileMessages.hC ?? 99999,
                                           wC:              fileMessages.wC ?? 99999,
                                           userGroupHash:   userGroupHash,
                                           typeCode:        fileMessages.typeCode,
                                           uniqueId:        fileMessages.uniqueId)
            } else {
                input = UploadImageRequest(dataToSend:      imageData,
                                           fileExtension:   fileMessages.fileExtension,
                                           fileName:        fileMessages.fileName,
                                           isPublic:        true,
                                           mimeType:        fileMessages.mimeType,
                                           originalName:     fileMessages.originalName,
                                           xC:              fileMessages.xC ?? 0,
                                           yC:              fileMessages.yC ?? 0,
                                           hC:              fileMessages.hC ?? 99999,
                                           wC:              fileMessages.wC ?? 99999,
                                           typeCode:        fileMessages.typeCode,
                                           uniqueId:        fileMessages.uniqueId)
            }
            upload = input
            
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
        
        let input: UploadImageRequest!
        if let userHash = uploadImageObj.userGroupHash {
            input = UploadImageRequest(dataToSend:      uploadImageObj.dataToSend!,
                                       fileExtension:   uploadImageObj.fileExtension,
                                       fileName:        uploadImageObj.fileName,
                                       mimeType:        uploadImageObj.mimeType,
                                       originalName:    uploadImageObj.originalName,
                                       xC:              uploadImageObj.xC,
                                       yC:              uploadImageObj.yC,
                                       hC:              uploadImageObj.hC,
                                       wC:              uploadImageObj.wC,
                                       userGroupHash:   userHash,
                                       typeCode:        uploadImageObj.typeCode,
                                       uniqueId:        uploadImageObj.uniqueId)
        } else {
            input = UploadImageRequest(dataToSend:      uploadImageObj.dataToSend!,
                                       fileExtension:   uploadImageObj.fileExtension,
                                       fileName:        uploadImageObj.fileName,
                                       isPublic:        true,
                                       mimeType:        uploadImageObj.mimeType,
                                       originalName:    uploadImageObj.originalName,
                                       xC:              uploadImageObj.xC,
                                       yC:              uploadImageObj.yC,
                                       hC:              uploadImageObj.hC,
                                       wC:              uploadImageObj.wC,
                                       typeCode:        uploadImageObj.typeCode,
                                       uniqueId:        uploadImageObj.uniqueId)
        }
        
        uploadImage(inputModel: input, uniqueId: { (uploadUniqueId) in
            uniqueId(uploadUniqueId)
        }, progress: { (theUploadProgress) in
            uploadProgress(theUploadProgress)
        }) { (uploadResponse) in
            completion(uploadResponse as! UploadImageModel)
        }
        
    }
    
    public func resend(uploadFileObj:   QueueOfWaitUploadFilesModel,
                       uniqueId:        @escaping (String)->(),
                       uploadProgress:  @escaping (Float)->(),
                       completion:      @escaping (UploadFileModel)->()) {
        
        let input: UploadFileRequest!
        if let userHash = uploadFileObj.userGroupHash {
            input = UploadFileRequest(dataToSend:       uploadFileObj.dataToSend!,
                                      fileExtension:    uploadFileObj.fileExtension,
                                      fileName:         uploadFileObj.fileName,
                                      mimeType:         uploadFileObj.mimeType,
                                      originalName:     uploadFileObj.originalName,
                                      userGroupHash:    userHash,
                                      typeCode:         uploadFileObj.typeCode,
                                      uniqueId:         uploadFileObj.uniqueId)
        } else {
            input = UploadFileRequest(dataToSend:       uploadFileObj.dataToSend!,
                                      fileExtension:    uploadFileObj.fileExtension,
                                      fileName:         uploadFileObj.fileName,
                                      isPublic:         true,
                                      mimeType:         uploadFileObj.mimeType,
                                      originalName:     uploadFileObj.originalName,
                                      typeCode:         uploadFileObj.typeCode,
                                      uniqueId:         uploadFileObj.uniqueId)
        }
        
        uploadFile(inputModel: input, uniqueId: { (uploadUniqueId) in
            uniqueId(uploadUniqueId)
        }, progress: { (theUploadProgress) in
            uploadProgress(theUploadProgress)
        }) { (uploadResponse) in
            completion(uploadResponse as! UploadFileModel)
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
