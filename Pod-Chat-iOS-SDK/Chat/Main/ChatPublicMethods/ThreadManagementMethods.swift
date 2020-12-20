//
//  ThreadManagementMethods.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 3/21/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import FanapPodAsyncSDK
import SwiftyJSON
import UIKit

// MARK: - Public Methods -
// MARK: - Thread Management

extension Chat {
    
    
    // MARK: - Close Thread
    /// closeThread:
    /// close a thread by Admin (only)
    ///
    /// By calling this function, a request of type 102 (CLOSE_THREAD) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "CreateThreadRequest" to this function
    ///
    /// Outputs:
    /// - It has 3 callbacks as responses
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (CloseThreadRequest)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion: (response) it will returns the response that comes from server to this request. (Any as! ThreadModel)
    public func closeThread(inputModel closeThreadInput: CloseThreadRequest,
                            uniqueId:       @escaping (String) -> (),
                            completion:     @escaping callbackTypeAlias) {

        log.verbose("Try to request to create thread participants with this parameters: \n \(closeThreadInput)", context: "Chat")
        uniqueId(closeThreadInput.uniqueId)

        closeThreadCallbackToUser = completion

        let chatMessage = SendChatMessageVO(chatMessageVOType:  ChatMessageVOTypes.CLOSE_THREAD.intValue(),
                                            content:            nil,
                                            messageType:        nil,
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          closeThreadInput.threadId,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           closeThreadInput.typeCode ?? generalTypeCode,
                                            uniqueId:           closeThreadInput.uniqueId,
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: nil)

        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  nil)

        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callbacks:          [(CloseThreadCallbacks(), closeThreadInput.uniqueId)],
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil)
    }
    
    
    
    // MARK: - Create Thread
    /// CreateThread:
    /// create a thread with somebody
    ///
    /// By calling this function, a request of type 1 (CREATE_THREAD) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "CreateThreadRequest" to this function
    ///
    /// Outputs:
    /// - It has 3 callbacks as responses
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (CreateThreadRequest)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion: (response) it will returns the response that comes from server to this request. (Any as! ThreadModel)
    public func createThread(inputModel createThreadInput: CreateThreadRequest,
                             uniqueId:          @escaping (String) -> (),
                             completion:        @escaping callbackTypeAlias) {
        
        log.verbose("Try to request to create thread participants with this parameters: \n \(createThreadInput)", context: "Chat")
        uniqueId(createThreadInput.uniqueId)
        
        createThreadCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  ChatMessageVOTypes.CREATE_THREAD.intValue(),
                                            content:            "\(createThreadInput.convertContentToJSON())",
                                            messageType:        nil,
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          nil,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           createThreadInput.typeCode ?? generalTypeCode,
                                            uniqueId:           createThreadInput.uniqueId,
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: nil)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  nil)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callbacks:          [(CreateThreadCallback(parameters: chatMessage), createThreadInput.uniqueId)],
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil)
    }
    
    
    // MARK: - Create Thread with Message
    /// CreateThreadAndSendMessage:
    /// create a thread with somebody and simultaneously send a message on this thread.
    ///
    /// By calling this function, a request of type 1 (CREATE_THREAD) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "CreateThreadWithMessageRequest" to this function
    ///
    /// Outputs:
    /// - It has 5 callbacks as responses
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (CreateThreadWithMessageRequest)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion: (response) it will returns the response that comes from server to this request. (Any as! ThreadModel)
    /// - parameter onSent:     (response) it will return this response if Sent Message comes from server, means that the message is sent successfully (Any as! SendMessageModel)
    /// - parameter onDelivere: (response) it will return this response if Deliver Message comes from server, means that the message is delivered to the destination (Any as! SendMessageModel)
    /// - parameter onSeen:     (response) it will return this response if Seen Message comes from server, means that the message is seen by the destination (Any as! SendMessageModel)
    public func createThreadWithMessage(inputModel creatThreadWithMessageInput: CreateThreadWithMessageRequest,
                                        threadUniqueId:     @escaping (String) -> (),
                                        messageUniqueId:    @escaping (String) -> (),
                                        completion:         @escaping callbackTypeAlias,
                                        onSent:             @escaping callbackTypeAlias,
                                        onDelivere:         @escaping callbackTypeAlias,
                                        onSeen:             @escaping callbackTypeAlias) {
        
        log.verbose("Try to request to create thread and Send Message participants with this parameters: \n \(creatThreadWithMessageInput)", context: "Chat")
        threadUniqueId(creatThreadWithMessageInput.createThreadInput.uniqueId)
        if let _ = creatThreadWithMessageInput.sendMessageInput {
            messageUniqueId(creatThreadWithMessageInput.sendMessageInput!.uniqueId)
        }
        
        createThreadCallbackToUser  = completion
        sendCallbackToUserOnSent    = onSent
        sendCallbackToUserOnDeliver = onDelivere
        sendCallbackToUserOnSeen    = onSeen
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  ChatMessageVOTypes.CREATE_THREAD.intValue(),
                                            content:            "\(creatThreadWithMessageInput.convertContentToJSON())",
                                            messageType:        nil, //creatThreadWithMessageInput.sendMessageInput?.messageType.returnIntValue()
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          nil,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           creatThreadWithMessageInput.createThreadInput.typeCode ?? generalTypeCode,
                                            uniqueId:           creatThreadWithMessageInput.createThreadInput.uniqueId,
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: true)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  nil)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callbacks:          [(CreateThreadCallback(parameters: chatMessage), creatThreadWithMessageInput.createThreadInput.uniqueId)],
                                sentCallback:       (creatThreadWithMessageInput.sendMessageInput != nil) ? (SendMessageCallbacks(parameters: chatMessage), [creatThreadWithMessageInput.sendMessageInput!.uniqueId]) : nil,
                                deliverCallback:    (creatThreadWithMessageInput.sendMessageInput != nil) ? (SendMessageCallbacks(parameters: chatMessage), [creatThreadWithMessageInput.sendMessageInput!.uniqueId]) : nil,
                                seenCallback:       (creatThreadWithMessageInput.sendMessageInput != nil) ? (SendMessageCallbacks(parameters: chatMessage), [creatThreadWithMessageInput.sendMessageInput!.uniqueId]) : nil)
    }
    
    
    // MARK: - Create Thread with FileMessage
    /// CreateThreadAndSendFileMessage:
    /// upload a File, then create a thread with somebody and simultaneously send a message on this thread.
    ///
    /// By calling this function, first an HTTP request will fires that will upload the image/file , then a request of type 1 (CREATE_THREAD) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "CreateThreadWithFileMessageRequest" to this function
    ///
    /// Outputs:
    /// - It has 5 callbacks as responses
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (CreateThreadWithFileMessageRequest)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion: (response) it will returns the response that comes from server to this request. (Any as! ThreadModel)
    /// - parameter onSent:     (response) it will return this response if Sent Message comes from server, means that the message is sent successfully (Any as! SendMessageModel)
    /// - parameter onDelivere: (response) it will return this response if Deliver Message comes from server, means that the message is delivered to the destination (Any as! SendMessageModel)
    /// - parameter onSeen:     (response) it will return this response if Seen Message comes from server, means that the message is seen by the destination (Any as! SendMessageModel)
    public func createThreadWithFileMessage(inputModel creatThreadWithFileMessageInput: CreateThreadWithFileMessageRequest,
                                            uploadUniqueId:         @escaping (String) -> (),
                                            uploadProgress:         @escaping (Float) -> (),
                                            uniqueId:               @escaping (String) -> (),
                                            createThreadCompletion: @escaping callbackTypeAlias,
                                            onSent:                 @escaping callbackTypeAlias,
                                            onDelivered:            @escaping callbackTypeAlias,
                                            onSeen:                 @escaping callbackTypeAlias) {
        
        log.verbose("Try to Send File and CreatThreadWithMessage with this parameters: \n \(creatThreadWithFileMessageInput)", context: "Chat")
        
//        uniqueId(creatThreadWithFileMessageInput.creatThreadWithMessageInput.createThreadInput.uniqueId)
        
        let createThreadInput = CreateThreadRequest(description: creatThreadWithFileMessageInput.creatThreadWithMessageInput.createThreadInput.description,
                                                    image:      creatThreadWithFileMessageInput.creatThreadWithMessageInput.createThreadInput.image,
                                                    invitees:   creatThreadWithFileMessageInput.creatThreadWithMessageInput.createThreadInput.invitees,
                                                    metadata:   creatThreadWithFileMessageInput.creatThreadWithMessageInput.createThreadInput.metadata,
                                                    title:      creatThreadWithFileMessageInput.creatThreadWithMessageInput.createThreadInput.title,
                                                    type:       creatThreadWithFileMessageInput.creatThreadWithMessageInput.createThreadInput.type,
                                                    uniqueName: creatThreadWithFileMessageInput.creatThreadWithMessageInput.createThreadInput.uniqueName,
                                                    typeCode:   creatThreadWithFileMessageInput.creatThreadWithMessageInput.createThreadInput.typeCode,
                                                    uniqueId:   creatThreadWithFileMessageInput.creatThreadWithMessageInput.createThreadInput.uniqueId)
        
        self.createThread(inputModel: createThreadInput, uniqueId: { _ in }) { (response) in
            
            guard let createThreadResponse: ThreadModel = response as? ThreadModel else { return }
            createThreadCompletion(createThreadResponse)
            if let uploadRequest = creatThreadWithFileMessageInput.uploadInput as? UploadImageRequest {
                uploadRequest.userGroupHash = createThreadResponse.thread!.userGroupHash
                sendFileMessage(withUploadInput: uploadRequest, inThreadId: createThreadResponse.thread!.id!)
            } else if let uploadRequest = creatThreadWithFileMessageInput.uploadInput as? UploadFileRequest {
                uploadRequest.userGroupHash = createThreadResponse.thread!.userGroupHash
                sendFileMessage(withUploadInput: uploadRequest, inThreadId: createThreadResponse.thread!.id!)
            }
            
        }
        
        
        func sendFileMessage(withUploadInput: UploadRequest, inThreadId: Int) {
            
            let messageInput = SendTextMessageRequest(messageType:      creatThreadWithFileMessageInput.creatThreadWithMessageInput.sendMessageInput?.messageType ?? MessageType.FILE,
                                                      metadata:         creatThreadWithFileMessageInput.creatThreadWithMessageInput.sendMessageInput?.metadata,
                                                      repliedTo:        nil,
                                                      systemMetadata:   creatThreadWithFileMessageInput.creatThreadWithMessageInput.sendMessageInput?.systemMetadata,
                                                      textMessage:      creatThreadWithFileMessageInput.creatThreadWithMessageInput.sendMessageInput?.text ?? "",
                                                      threadId:         inThreadId,
                                                      typeCode:         creatThreadWithFileMessageInput.creatThreadWithMessageInput.createThreadInput.typeCode,
                                                      uniqueId:         creatThreadWithFileMessageInput.creatThreadWithMessageInput.sendMessageInput?.uniqueId)
            let sendMessageInput = SendReplyFileMessageRequest(messageInput: messageInput, uploadInput: withUploadInput)
            self.sendFileMessage(inputModel: sendMessageInput, uploadUniqueId: { (uploadFileUniqueId) in
                uploadUniqueId(uploadFileUniqueId)
            }, uploadProgress: { (progress) in
                uploadProgress(progress)
            }, messageUniqueId: { (messageUniqueId) in
                uniqueId(messageUniqueId)
            }, onSent: { (sent) in
                onSent(sent)
            }, onDelivered: { (delivered) in
                onDelivered(delivered)
            }) { (seen) in
                onSeen(seen)
            }
        }
        
        
        
        
        
//        var metadata: JSON = [:]
//
//        if let uploadRequest = creatThreadWithFileMessageInput.uploadInput as? UploadImageRequestModel  {
//
//            metadata["file"]["originalName"] = JSON(uploadRequest.fileName)
//            metadata["file"]["mimeType"]    = JSON("")
//            metadata["file"]["size"]        = JSON(uploadRequest.fileSize)
//
//            uploadImage(inputModel: uploadRequest,
//                        uniqueId: { (uploadImageUniqueId) in
//                uploadUniqueId(uploadImageUniqueId)
//            }, progress: { (progress) in
//                            uploadProgress(progress)
//            }) { (response) in
//                let myResponse: UploadImageModel = response as! UploadImageModel
//                metadata["file"] = myResponse.returnMetaData(onServiceAddress: self.SERVICE_ADDRESSES.FILESERVER_ADDRESS)
//                createThreadAndSendMessage(withMetadata: metadata)
//            }
//
//        } else if let uploadRequest = creatThreadWithFileMessageInput.uploadInput as? UploadFileRequestModel {
//
//            metadata["file"]["originalName"] = JSON(uploadRequest.fileName)
//            metadata["file"]["mimeType"]    = JSON("")
//            metadata["file"]["size"]        = JSON(uploadRequest.fileSize)
//
//            uploadFile(inputModel: uploadRequest,
//                       uniqueId: { (uploadFileUniqueId) in
//                uploadUniqueId(uploadFileUniqueId)
//            }, progress: { (progress) in
//                uploadProgress(progress)
//            }) { (response) in
//                let myResponse: UploadFileModel = response as! UploadFileModel
//                metadata["file"]    = myResponse.returnMetaData(onServiceAddress: self.SERVICE_ADDRESSES.FILESERVER_ADDRESS)
//                createThreadAndSendMessage(withMetadata: metadata)
//            }
//
//        }
//
//        // this will call when all data were uploaded and it will sends the textMessage
//        func createThreadAndSendMessage(withMetadata: JSON) {
//            let createThreadSendMessageParamModel = CreateThreadWithMessageRequestModel(createThreadInput:  creatThreadWithFileMessageInput.creatThreadWithMessageInput.createThreadInput,
//                                                                                        sendMessageInput:   creatThreadWithFileMessageInput.creatThreadWithMessageInput.sendMessageInput)
//            createThreadSendMessageParamModel.sendMessageInput?.metadata = "\(withMetadata)"
//
//            self.createThreadWithMessage(inputModel: createThreadSendMessageParamModel, threadUniqueId: { _ in }, messageUniqueId: { _ in }, completion: { (createThreadResponse) in
//                completion(createThreadResponse)
//            }, onSent: { (sent) in
//                onSent(sent)
//            }, onDelivere: { (delivered) in
//                onDelivered(delivered)
//            }) { (seen) in
//                onSeen(seen)
//            }
//
//        }
        
    }
    
    
    // MARK: - Get Thread
    /// GetAllThreads:
    /// this function will get all user threads
    ///
    /// By calling this function, a request of type 14 (GET_THREADS) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "GetAllThreadsRequest" to this function
    ///
    /// Outputs:
    /// - this function has no output
    ///
    /// - parameter inputModel:         (input) you have to send your parameters insid this model. (GetAllThreadsRequest)
    func getAllThreads(withInputModel input:   GetAllThreadsRequest) {
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  ChatMessageVOTypes.GET_THREADS.intValue(),
                                            content:            "\(input.convertContentToJSON())",
                                            messageType:        nil,
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          nil,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           input.typeCode ?? generalTypeCode,
                                            uniqueId:           nil,
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: nil)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  nil)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callbacks:          [(GetThreadsCallbacks(parameters: chatMessage), "")],
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil)
    }
    
    
    // MARK: - Get Thread
    /// GetThreads:
    /// this function will get threads of the user
    ///
    /// By calling this function, a request of type 14 (GET_THREADS) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "GetThreadsRequest" to this function
    ///
    /// Outputs:
    /// - It has 3 callbacks as responses
    ///
    /// - parameter inputModel:         (input) you have to send your parameters insid this model. (GetThreadsRequest)
    /// - parameter getCacheResponse:   (input) specify if you want to get cache response for this request (Bool?)
    /// - parameter uniqueId:           (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion:         (response) it will returns the response that comes from server to this request. (Any as! GetThreadsModel)
    /// - parameter cacheResponse:      (response) there is another response that comes from CacheDB to the user, if user has set 'enableCache' vaiable to be true. (GetThreadsModel)
    public func getThreads(inputModel getThreadsInput:  GetThreadsRequest,
                           getCacheResponse:            Bool?,
                           uniqueId:            @escaping (String) -> (),
                           completion:          @escaping callbackTypeAlias,
                           cacheResponse:       @escaping (GetThreadsModel) -> ()) {
        
        log.verbose("Try to request to get threads with this parameters: \n \(getThreadsInput)", context: "Chat")
        uniqueId(getThreadsInput.uniqueId)
        
        threadsCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  ChatMessageVOTypes.GET_THREADS.intValue(),
                                            content:            "\(getThreadsInput.convertContentToJSON())",
                                            messageType:        nil,
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          nil,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           getThreadsInput.typeCode ?? generalTypeCode,
                                            uniqueId:           getThreadsInput.uniqueId,
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: nil)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  nil)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callbacks:          [(GetThreadsCallbacks(parameters: chatMessage), getThreadsInput.uniqueId)],
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil)
        
        // if cache is enabled by user, it will return cache result to the user
        if (getCacheResponse ?? enableCache) {
            if getThreadsInput.new ?? false {
                if let cacheThreads = Chat.cacheDB.retrieveNewThreads(count:    getThreadsInput.count ?? 50,
                                                                      offset:   getThreadsInput.offset ?? 0) {
                    cacheResponse(cacheThreads)
                }
            } else {
                if let cacheThreads = Chat.cacheDB.retrieveThreads(ascending:   false,
                                                                   count:       getThreadsInput.count ?? 50,
                                                                   name:        getThreadsInput.threadName,
                                                                   offset:      getThreadsInput.offset ?? 0,
                                                                   threadIds:   getThreadsInput.threadIds) {
                    cacheResponse(cacheThreads)
                }
            }
            
        }
        
    }
    
    // MARK: - IsAvailable Thread
    /// IsNameAvailable:
    /// this function will check if the public name is available or not
    ///
    /// By calling this function, a request of type 34 (IS_NAME_AVAILABLE) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "IsPublicThreadNameAvailableRequest" to this function
    ///
    /// Outputs:
    /// - It has 3 callbacks as responses
    ///
    /// - parameter inputModel:         (input) you have to send your parameters insid this model. (IsPublicThreadNameAvailableRequest)
    /// - parameter uniqueId:           (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion:         (response) it will returns the response that comes from server to this request. (Any as! IsAvailableNameModel)
    public func isNameAvailable(inputModel isNameAvailableThreadInput: IsPublicThreadNameAvailableRequest,
                                uniqueId:       @escaping (String) -> (),
                                completion:     @escaping callbackTypeAlias) {
        
        log.verbose("Try to request to join thread with this parameters: \n \(isNameAvailableThreadInput.convertContentToJSON())", context: "Chat")
        uniqueId(isNameAvailableThreadInput.uniqueId)
        
        isPublicThreadNameAvailableCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  ChatMessageVOTypes.IS_NAME_AVAILABLE.intValue(),
                                            content:            "\(isNameAvailableThreadInput.uniqueName)",
                                            messageType:        nil,
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          nil,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           isNameAvailableThreadInput.typeCode ?? generalTypeCode,
                                            uniqueId:           isNameAvailableThreadInput.uniqueId,
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: true)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  nil)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callbacks:          [(IsPublicThreadNameAvailableCallbacks(), isNameAvailableThreadInput.uniqueId)],
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil)
        
    }
    
    
    // MARK: - Join Thread
    /// JoinPublicThread:
    /// by calling this function, user will join the public thread
    ///
    /// By calling this function, a request of type 34 (IS_NAME_AVAILABLE) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "JoinPublicThreadRequest" to this function
    ///
    /// Outputs:
    /// - It has 3 callbacks as responses
    ///
    /// - parameter inputModel:         (input) you have to send your parameters insid this model. (JoinPublicThreadRequest)
    /// - parameter uniqueId:           (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion:         (response) it will returns the response that comes from server to this request. (Any as! ThreadModel)
    public func joinThread(inputModel joinThreadInput: JoinPublicThreadRequest,
                           uniqueId:        @escaping (String) -> (),
                           completion:      @escaping callbackTypeAlias) {
        
        log.verbose("Try to request to join thread with this parameters: \n uniqueName = \(joinThreadInput.uniqueName)", context: "Chat")
        uniqueId(joinThreadInput.uniqueId)
        
        joinPublicThreadCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  ChatMessageVOTypes.JOIN_THREAD.intValue(),
                                            content:            joinThreadInput.uniqueName,
                                            messageType:        nil,
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          nil,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           joinThreadInput.typeCode ?? generalTypeCode,
                                            uniqueId:           joinThreadInput.uniqueId,
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: true)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  nil)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callbacks:          [(JoinPublicThreadCallbacks(), joinThreadInput.uniqueId)],
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil)
        
    }
    
    
    // MARK: - Leave Thread
    
    /// LeaveThread:
    /// leave from a specific thread.
    ///
    /// By calling this function, a request of type 9 (LEAVE_THREAD) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "LeaveThreadRequest" to this function
    ///
    /// Outputs:
    /// - It has 2 callbacks as responses
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (LeaveThreadRequest)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion: (response) it will returns the response that comes from server to this request. (Any as! ThreadModel)
    public func leaveThread(inputModel leaveThreadInput:   LeaveThreadRequest,
                            uniqueId:       @escaping (String) -> (),
                            completion:     @escaping callbackTypeAlias) {
        
        log.verbose("Try to request to leave thread with this parameters: \n \(leaveThreadInput)", context: "Chat")
        uniqueId(leaveThreadInput.uniqueId)
        
        leaveThreadCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  ChatMessageVOTypes.LEAVE_THREAD.intValue(),
                                            content:            "\(leaveThreadInput.convertContentToJSON())",
                                            messageType:        nil,
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          leaveThreadInput.threadId,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           leaveThreadInput.typeCode ?? generalTypeCode,
                                            uniqueId:           leaveThreadInput.uniqueId,
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: true)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  nil)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callbacks:          [(LeaveThreadCallbacks(), leaveThreadInput.uniqueId)],
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil)
    }
    
    
    /// LeaveThreadSaftly:
    /// safe leave from a specific thread.
    ///
    /// By calling this function, a request of type 9 (LEAVE_THREAD) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "SafeLeaveThreadRequest" to this function
    /// - we will check the userRole if he/she has the correct Role to add admin to the thread
    ///
    /// Outputs:
    /// - It has 2 callbacks as responses
    /// - if user has no adminRoles, we will return failed response as an event
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (SafeLeaveThreadRequest)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion: (response) it will returns the response that comes from server to this request. (Any as! ThreadModel)
    public func leaveThreadSaftly(inputModel safeLeaveThreadInput:   SafeLeaveThreadRequest,
                                  uniqueId:             @escaping (String) -> (),
                                  addAdminCallback:     @escaping callbackTypeAlias,
                                  leaveThreadCallback:  @escaping callbackTypeAlias) {
        
        log.verbose("Try to request to leave saftly from thread with this parameters: \n \(safeLeaveThreadInput)", context: "Chat")

        let currentRolesInput = GetCurrentUserRolesRequest(threadId: safeLeaveThreadInput.threadId,
                                                           typeCode: safeLeaveThreadInput.typeCode,
                                                           uniqueId: nil)
        getCurrentUserRoles(inputModel: currentRolesInput,
                            getCacheResponse: false,
                            uniqueId: { _ in },
                            completion: { (currentUserRolesResponse) in
            let userRolesResponse = currentUserRolesResponse as! GetCurrentUserRolesModel
            var isAdmin = false
            let roles = userRolesResponse.userRoles
            for item in userRolesResponse.userRoles {
                if (item == Roles.ADD_RULE_TO_USER) || (item == Roles.THREAD_ADMIN) {
                    isAdmin = true
                }
            }
            
            if isAdmin {
                
                let setRoleModel = SetRemoveRoleModel(userId: safeLeaveThreadInput.participantId, roles: roles)
                let adminInput = RoleRequestModel(userRoles: [setRoleModel],
                                                  threadId: safeLeaveThreadInput.threadId,
                                                  typeCode: nil,
                                                  uniqueId: nil)
                
                self.setRole(inputModel: adminInput, uniqueId: { _ in }) { (setAdminResponse) in
                    addAdminCallback(setAdminResponse)
                    self.leaveThread(inputModel: safeLeaveThreadInput.convertToLeaveThreadRequest(),
                                     uniqueId: { (leaveThreadUniqueId) in
                        uniqueId(leaveThreadUniqueId)
                    }) { (leaveThreadResponse) in
                        leaveThreadCallback(leaveThreadResponse)
                    }
                }

            } else {
                let eventModel = ThreadEventModel(type:         ThreadEventTypes.THREAD_LEAVE_SAFTLY_FAILED,
                                                  participants: nil,
                                                  threads:      nil,
                                                  threadId:     safeLeaveThreadInput.threadId,
                                                  senderId:     nil,
                                                  unreadCount:  nil,
                                                  pinMessage:   nil)
                self.delegate?.threadEvents(model: eventModel)
                let leaveThreadModel = ThreadResponse(messageContent:   JSON(),
                                                      hasError:         true,
                                                      errorMessage:     "Current User have no Permission to Change the ThreadAdmin",
                                                      errorCode:        6666)
                leaveThreadCallback(leaveThreadModel)
            }
                                
        }) { _ in }
        
    }
    
    
    // MARK: - Mute Thread
    /// MuteThread:
    /// mute a thread
    ///
    /// By calling this function, a request of type 19 (MUTE_THREAD) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "MuteUnmuteThreadRequest" to this function
    ///
    /// Outputs:
    /// - It has 2 callbacks as responses.
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (MuteUnmuteThreadRequest)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion: (response) it will returns the response that comes from server to this request. (Any as! MuteUnmuteThreadModel)
    public func muteThread(inputModel muteThreadInput: MuteUnmuteThreadRequest,
                           uniqueId:        @escaping (String) -> (),
                           completion:      @escaping callbackTypeAlias) {
        
        log.verbose("Try to request to mute threads with this parameters: \n \(muteThreadInput)", context: "Chat")
        uniqueId(muteThreadInput.uniqueId)
        
        muteThreadCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  ChatMessageVOTypes.MUTE_THREAD.intValue(),
                                            content:            nil,
                                            messageType:        nil,
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          muteThreadInput.subjectId,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           muteThreadInput.typeCode ?? generalTypeCode,
                                            uniqueId:           muteThreadInput.uniqueId,
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: true)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  nil)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callbacks:          [(MuteThreadCallbacks(), muteThreadInput.uniqueId)],
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil)
    }
    
    
    // MARK: - Unmute Thread
    /// UnmuteThread:
    /// unmute a thread
    ///
    /// By calling this function, a request of type 20 (UNMUTE_THREAD) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "MuteUnmuteThreadRequest" to this function
    ///
    /// Outputs:
    /// - It has 2 callbacks as responses.
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (MuteUnmuteThreadRequest)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion: (response) it will returns the response that comes from server to this request. (Any as! MuteUnmuteThreadModel)
    public func unmuteThread(inputModel unmuteThreadInput: MuteUnmuteThreadRequest,
                             uniqueId:          @escaping (String) -> (),
                             completion:        @escaping callbackTypeAlias) {
        
        log.verbose("Try to request to unmute threads with this parameters: \n \(unmuteThreadInput)", context: "Chat")
        uniqueId(unmuteThreadInput.uniqueId)
        
        unmuteThreadCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  ChatMessageVOTypes.UNMUTE_THREAD.intValue(),
                                            content:            nil,
                                            messageType:        nil,
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          unmuteThreadInput.subjectId,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           unmuteThreadInput.typeCode ?? generalTypeCode,
                                            uniqueId:           unmuteThreadInput.uniqueId,
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: true)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  nil)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callbacks:          [(UnmuteThreadCallbacks(), unmuteThreadInput.uniqueId)],
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil)
    }
    
    
    // MARK: - Pin Thread
    /// PinThread:
    /// pin a thread
    ///
    /// By calling this function, a request of type 48 (PIN_THREAD) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "PinUnpinThreadRequest" to this function
    ///
    /// Outputs:
    /// - It has 2 callbacks as responses.
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (PinUnpinThreadRequest)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion: (response) it will returns the response that comes from server to this request. (Any as! PinUnpinThreadModel)
    public func pinThread(inputModel pinThreadInput: PinUnpinThreadRequest,
                           uniqueId:        @escaping (String) -> (),
                           completion:      @escaping callbackTypeAlias) {
        
        log.verbose("Try to request to pin threads with this parameters: \n \(pinThreadInput)", context: "Chat")
        uniqueId(pinThreadInput.uniqueId)
        
        pinThreadCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  ChatMessageVOTypes.PIN_THREAD.intValue(),
                                            content:            nil,
                                            messageType:        nil,
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          pinThreadInput.threadId,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           pinThreadInput.typeCode ?? generalTypeCode,
                                            uniqueId:           pinThreadInput.uniqueId,
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: true)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  nil)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callbacks:          [(PinThreadCallbacks(), pinThreadInput.uniqueId)],
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil)
    }
    
    
    
    // MARK: - Unpin Thread
    /// UnpinThread:
    /// unpin a thread
    ///
    /// By calling this function, a request of type 49 (UNPIN_THREAD) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "PinUnpinThreadRequest" to this function
    ///
    /// Outputs:
    /// - It has 2 callbacks as responses.
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (PinUnpinThreadRequest)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion: (response) it will returns the response that comes from server to this request. (Any as! PinUnpinThreadModel)
    public func unpinThread(inputModel unpinThreadInput: PinUnpinThreadRequest,
                            uniqueId:       @escaping (String) -> (),
                            completion:     @escaping callbackTypeAlias) {
    
        log.verbose("Try to request to unpin threads with this parameters: \n \(unpinThreadInput)", context: "Chat")
        uniqueId(unpinThreadInput.uniqueId)
        
        unpinThreadCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  ChatMessageVOTypes.UNPIN_THREAD.intValue(),
                                            content:            nil,
                                            messageType:        nil,
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          unpinThreadInput.threadId,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           unpinThreadInput.typeCode ?? generalTypeCode,
                                            uniqueId:           unpinThreadInput.uniqueId,
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: true)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                                msgTTL:       msgTTL,
                                                peerName:     serverName,
                                                priority:     msgPriority,
                                                pushMsgType:  nil)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callbacks:          [(UnpinThreadCallbacks(), unpinThreadInput.uniqueId)],
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil)
    }
    
    
    // MARK: - Spam Thread
    /// SpamPVThread:
    /// spam a thread.
    ///
    /// By calling this function, a request of type 41 (SPAM_PV_THREAD) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "SpamPrivateThreadRequest" to this function
    ///
    /// Outputs:
    /// - It has 2 callbacks as responses. the las callback will come 3 times : for LeaveThread response, for BlockContact response, for ClearHistory response
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (SpamPrivateThreadRequest)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion: (response) it will returns the response that comes from server to this request for 3 times!. (Any as! ThreadModel) (Any as! BlockedUserModel) (Any as! ClearHistoryModel)
    public func spamPvThread(inputModel spamPvThreadInput: SpamPrivateThreadRequest,
                             uniqueId:          @escaping (String) -> (),
                             completions:       @escaping callbackTypeAlias) {
        
        log.verbose("Try to request to spam thread with this parameters: \n \(spamPvThreadInput)", context: "Chat")
        uniqueId(spamPvThreadInput.uniqueId)
        
        spamPvThreadCallbackToUser = completions
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  ChatMessageVOTypes.SPAM_PV_THREAD.intValue(),
                                            content:            nil,
                                            messageType:        nil,
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          spamPvThreadInput.threadId,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           spamPvThreadInput.typeCode ?? generalTypeCode,
                                            uniqueId:           spamPvThreadInput.uniqueId,
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: true)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  nil)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callbacks:          [(SpamPrivateThread(), spamPvThreadInput.uniqueId)],
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil)
    }
    
    
    // MARK: - Update Thread
    /// UpdateThreadInfo:
    /// update information about a thread.
    ///
    /// By calling this function, a request of type 30 (UPDATE_THREAD_INFO) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "UpdateThreadInfoRequest" to this function
    ///
    /// Outputs:
    /// - It has 2 callbacks as responses
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (UpdateThreadInfoRequest)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion: (response) it will returns the response that comes from server to this request. (Any as! GetThreadsModel)
    public func updateThreadInfo(inputModel updateThreadInfoInput: UpdateThreadInfoRequest,
                                 uploadUniqueId:    @escaping (String) -> (),
                                 uploadProgress:    @escaping (Float) -> (),
                                 uniqueId:          @escaping (String) -> (),
                                 completion:        @escaping callbackTypeAlias) {
        
        log.verbose("Try to request to update thread info with this parameters: \n \(updateThreadInfoInput)", context: "Chat")
        uniqueId(updateThreadInfoInput.uniqueId)
        
        updateThreadInfoCallbackToUser = completion
        
        var content: JSON = updateThreadInfoInput.convertContentToJSON()
        
        func sendRequest() {
            let chatMessage = SendChatMessageVO(chatMessageVOType:  ChatMessageVOTypes.UPDATE_THREAD_INFO.intValue(),
                                                content:            "\(content)",
                                                messageType:        nil,
                                                metadata:           nil,
                                                repliedTo:          nil,
                                                systemMetadata:     nil,
                                                subjectId:          updateThreadInfoInput.threadId,
                                                token:              token,
                                                tokenIssuer:        nil,
                                                typeCode:           updateThreadInfoInput.typeCode ?? generalTypeCode,
                                                uniqueId:           updateThreadInfoInput.uniqueId,
                                                uniqueIds:          nil,
                                                isCreateThreadAndSendMessage: nil)
            
            let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                                  msgTTL:       msgTTL,
                                                  peerName:     serverName,
                                                  priority:     msgPriority,
                                                  pushMsgType:  nil)
            
            sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                    callbacks:          [(UpdateThreadInfoCallback(), updateThreadInfoInput.uniqueId)],
                                    sentCallback:       nil,
                                    deliverCallback:    nil,
                                    seenCallback:       nil)
        }
        
        if let uploadInput = updateThreadInfoInput.threadImage {
            uploadImage(inputModel: uploadInput, uniqueId: { (uploadUId) in
                uploadUniqueId(uploadUId)
            }, progress: { (progress) in
                uploadProgress(progress)
            }) { (response) in
                let uploadResponse = response as! UploadImageResponse
                
                var metadata: JSON = [:]
                if let md = updateThreadInfoInput.metadata?.convertToJSON() {
                    metadata = md
                }
                if let type = uploadResponse.uploadImage?.type {
                    metadata["type"] = JSON(type)
                }
                if let name = uploadResponse.uploadImage?.name {
                    metadata["name"] = JSON(name)
                }
                if let size = uploadResponse.uploadImage?.size {
                    metadata["size"] = JSON(size)
                }
                if let hashCode = uploadResponse.uploadImage?.hashCode {
                    metadata["hashCode"] = JSON(hashCode)
                }
                updateThreadInfoInput.metadata = "\(metadata)"
                content = updateThreadInfoInput.convertContentToJSON()
                
//                content["hashCode"] = JSON(uploadResponse.uploadImage?.hashCode)
//                let uploadJSON = uploadResponse.returnDataAsJSON()
//                content = updateThreadInfoInput.convertContentToJSON().merged(other: uploadJSON)
                sendRequest()
            }
        } else {
            sendRequest()
        }
        
        
    }
    
    
    
    
    
    

    
    
    
}


