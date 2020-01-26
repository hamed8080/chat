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

// MARK: - Public Methods -
// MARK: - Thread Management

extension Chat {
    
    // MARK: - Get/Update Thread
    
    func getAllThreads(withInputModel input:   GetAllThreadsRequestModel) {
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.GET_THREADS.rawValue,
                                            content:            "\(input.convertContentToJSON())",
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
    
    
    /// GetThreads:
    /// this function will get threads of the user
    ///
    /// By calling this function, a request of type 14 (GET_THREADS) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "GetThreadsRequestModel" to this function
    ///
    /// Outputs:
    /// - It has 3 callbacks as responses
    ///
    /// - parameter inputModel:     (input) you have to send your parameters insid this model. (GetThreadsRequestModel)
    /// - parameter uniqueId:       (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion:     (response) it will returns the response that comes from server to this request. (Any as! GetThreadsModel)
    /// - parameter cacheResponse:  (response) there is another response that comes from CacheDB to the user, if user has set 'enableCache' vaiable to be true. (GetThreadsModel)
    public func getThreads(inputModel getThreadsInput: GetThreadsRequestModel,
                           uniqueId:        @escaping (String) -> (),
                           completion:      @escaping callbackTypeAlias,
                           cacheResponse:   @escaping (GetThreadsModel) -> ()) {
        
        log.verbose("Try to request to get threads with this parameters: \n \(getThreadsInput)", context: "Chat")
        uniqueId(getThreadsInput.uniqueId)
        
        threadsCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.GET_THREADS.rawValue,
                                            content:            "\(getThreadsInput.convertContentToJSON())",
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
        if enableCache {
            if let cacheThreads = Chat.cacheDB.retrieveThreads(ascending:   false,
                                                               count:       getThreadsInput.count ?? 50,
                                                               name:        getThreadsInput.name,
                                                               offset:      getThreadsInput.offset ?? 0,
                                                               threadIds:   getThreadsInput.threadIds/*,
                                                               timeStamp:   cacheTimeStamp*/) {
                cacheResponse(cacheThreads)
            }
        }
        
    }
    
    
    /// UpdateThreadInfo:
    /// update information about a thread.
    ///
    /// By calling this function, a request of type 30 (UPDATE_THREAD_INFO) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "UpdateThreadInfoRequestModel" to this function
    ///
    /// Outputs:
    /// - It has 2 callbacks as responses
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (UpdateThreadInfoRequestModel)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion: (response) it will returns the response that comes from server to this request. (Any as! GetThreadsModel)
    public func updateThreadInfo(inputModel updateThreadInfoInput: UpdateThreadInfoRequestModel,
                                 uniqueId:              @escaping (String) -> (),
                                 completion:            @escaping callbackTypeAlias) {
        
        log.verbose("Try to request to update thread info with this parameters: \n \(updateThreadInfoInput)", context: "Chat")
        uniqueId(updateThreadInfoInput.uniqueId)
        
        updateThreadInfoCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.UPDATE_THREAD_INFO.rawValue,
                                            content:            "\(updateThreadInfoInput.convertContentToJSON())",
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
    
    
    // MARK: - Create Thread
    
    /// CreateThread:
    /// create a thread with somebody
    ///
    /// By calling this function, a request of type 1 (CREATE_THREAD) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "CreateThreadRequestModel" to this function
    ///
    /// Outputs:
    /// - It has 3 callbacks as responses
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (CreateThreadRequestModel)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion: (response) it will returns the response that comes from server to this request. (Any as! ThreadModel)
    public func createThread(inputModel createThreadInput: CreateThreadRequestModel,
                             uniqueId:          @escaping (String) -> (),
                             completion:        @escaping callbackTypeAlias) {
        
        log.verbose("Try to request to create thread participants with this parameters: \n \(createThreadInput)", context: "Chat")
        uniqueId(createThreadInput.uniqueId)
        
        createThreadCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.CREATE_THREAD.rawValue,
                                            content:            "\(createThreadInput.convertContentToJSON())",
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
    
    
    /// CreateThreadAndSendMessage:
    /// create a thread with somebody and simultaneously send a message on this thread.
    ///
    /// By calling this function, a request of type 1 (CREATE_THREAD) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "CreateThreadWithMessageRequestModel" to this function
    ///
    /// Outputs:
    /// - It has 5 callbacks as responses
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (CreateThreadWithMessageRequestModel)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion: (response) it will returns the response that comes from server to this request. (Any as! ThreadModel)
    /// - parameter onSent:     (response) it will return this response if Sent Message comes from server, means that the message is sent successfully (Any as! SendMessageModel)
    /// - parameter onDelivere: (response) it will return this response if Deliver Message comes from server, means that the message is delivered to the destination (Any as! SendMessageModel)
    /// - parameter onSeen:     (response) it will return this response if Seen Message comes from server, means that the message is seen by the destination (Any as! SendMessageModel)
    public func createThreadWithMessage(inputModel creatThreadWithMessageInput: CreateThreadWithMessageRequestModel,
                                        threadUniqueId:                         @escaping (String) -> (),
                                        messageUniqueId:                        @escaping (String) -> (),
                                        completion:                             @escaping callbackTypeAlias,
                                        onSent:                                 @escaping callbackTypeAlias,
                                        onDelivere:                             @escaping callbackTypeAlias,
                                        onSeen:                                 @escaping callbackTypeAlias) {
        
        log.verbose("Try to request to create thread and Send Message participants with this parameters: \n \(creatThreadWithMessageInput)", context: "Chat")
        threadUniqueId(creatThreadWithMessageInput.createThreadInput.uniqueId)
        if let _ = creatThreadWithMessageInput.sendMessageInput {
            messageUniqueId(creatThreadWithMessageInput.sendMessageInput!.uniqueId)
        }
        
        createThreadCallbackToUser  = completion
        sendCallbackToUserOnSent    = onSent
        sendCallbackToUserOnDeliver = onDelivere
        sendCallbackToUserOnSeen    = onSeen
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.CREATE_THREAD.rawValue,
                                            content:            "\(creatThreadWithMessageInput.convertContentToJSON())",
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
    
    
    /// CreateThreadAndSendFileMessage:
    /// upload a File, then create a thread with somebody and simultaneously send a message on this thread.
    ///
    /// By calling this function, first an HTTP request will fires that will upload the image/file , then a request of type 1 (CREATE_THREAD) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "CreateThreadWithMessageRequestModel" to this function
    ///
    /// Outputs:
    /// - It has 5 callbacks as responses
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (CreateThreadWithMessageRequestModel)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion: (response) it will returns the response that comes from server to this request. (Any as! ThreadModel)
    /// - parameter onSent:     (response) it will return this response if Sent Message comes from server, means that the message is sent successfully (Any as! SendMessageModel)
    /// - parameter onDelivere: (response) it will return this response if Deliver Message comes from server, means that the message is delivered to the destination (Any as! SendMessageModel)
    /// - parameter onSeen:     (response) it will return this response if Seen Message comes from server, means that the message is seen by the destination (Any as! SendMessageModel)
    public func createThreadWithFileMessage(inputModel creatThreadWithFileMessageInput: CreateThreadWithFileMessageRequestModel,
                                            uploadUniqueId:     @escaping (String) -> (),
                                            uploadProgress:     @escaping (Float) -> (),
                                            uniqueId:           @escaping (String) -> (),
                                            completion:         @escaping callbackTypeAlias,
                                            onSent:             @escaping callbackTypeAlias,
                                            onDelivered:        @escaping callbackTypeAlias,
                                            onSeen:             @escaping callbackTypeAlias) {
        
        log.verbose("Try to Send File and CreatThreadWithMessage with this parameters: \n \(creatThreadWithFileMessageInput)", context: "Chat")
        
        uniqueId(creatThreadWithFileMessageInput.creatThreadWithMessageInput.createThreadInput.uniqueId)
        
        var metadata: JSON = [:]
        
        if let uploadRequest = creatThreadWithFileMessageInput.uploadInput as? UploadImageRequestModel  {
            
            metadata["file"]["originalName"] = JSON(uploadRequest.originalFileName)
            metadata["file"]["mimeType"]    = JSON("")
            metadata["file"]["size"]        = JSON(uploadRequest.fileSize)
            
            uploadImage(inputModel: uploadRequest,
                        uniqueId: { (uploadImageUniqueId) in
                uploadUniqueId(uploadImageUniqueId)
            }, progress: { (progress) in
                            uploadProgress(progress)
            }) { (response) in
                let myResponse: UploadImageModel = response as! UploadImageModel
                metadata["file"] = myResponse.returnMetaData(onServiceAddress: self.SERVICE_ADDRESSES.FILESERVER_ADDRESS)
                createThreadAndSendMessage(withMetadata: metadata)
            }
            
        } else if let uploadRequest = creatThreadWithFileMessageInput.uploadInput as? UploadFileRequestModel {
            
            metadata["file"]["originalName"] = JSON(uploadRequest.originalFileName)
            metadata["file"]["mimeType"]    = JSON("")
            metadata["file"]["size"]        = JSON(uploadRequest.fileSize)
            
            uploadFile(inputModel: uploadRequest,
                       uniqueId: { (uploadFileUniqueId) in
                uploadUniqueId(uploadFileUniqueId)
            }, progress: { (progress) in
                uploadProgress(progress)
            }) { (response) in
                let myResponse: UploadFileModel = response as! UploadFileModel
                metadata["file"]    = myResponse.returnMetaData(onServiceAddress: self.SERVICE_ADDRESSES.FILESERVER_ADDRESS)
                createThreadAndSendMessage(withMetadata: metadata)
            }
            
        }
        
        // this will call when all data were uploaded and it will sends the textMessage
        func createThreadAndSendMessage(withMetadata: JSON) {
            let createThreadSendMessageParamModel = CreateThreadWithMessageRequestModel(createThreadInput:  creatThreadWithFileMessageInput.creatThreadWithMessageInput.createThreadInput,
                                                                                        sendMessageInput:   creatThreadWithFileMessageInput.creatThreadWithMessageInput.sendMessageInput)
            createThreadSendMessageParamModel.sendMessageInput?.metadata = "\(withMetadata)"
            
            self.createThreadWithMessage(inputModel: createThreadSendMessageParamModel, threadUniqueId: { _ in }, messageUniqueId: { _ in }, completion: { (createThreadResponse) in
                completion(createThreadResponse)
            }, onSent: { (sent) in
                onSent(sent)
            }, onDelivere: { (delivered) in
                onDelivered(delivered)
            }) { (seen) in
                onSeen(seen)
            }
            
        }
        
    }
    
    
    // MARK: - Leave/Spam Thread
    
    /// LeaveThread:
    /// leave from a specific thread.
    ///
    /// By calling this function, a request of type 9 (LEAVE_THREAD) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "LeaveThreadRequestModel" to this function
    ///
    /// Outputs:
    /// - It has 2 callbacks as responses
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (LeaveThreadRequestModel)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion: (response) it will returns the response that comes from server to this request. (Any as! ThreadModel)
    public func leaveThread(inputModel leaveThreadInput:   LeaveThreadRequestModel,
                            uniqueId:           @escaping (String) -> (),
                            completion:         @escaping callbackTypeAlias) {
        
        log.verbose("Try to request to leave thread with this parameters: \n \(leaveThreadInput)", context: "Chat")
        uniqueId(leaveThreadInput.uniqueId)
        
        leaveThreadCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.LEAVE_THREAD.rawValue,
                                            content:            nil,
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
    
    
    /// SpamPVThread:
    /// spam a thread.
    ///
    /// By calling this function, a request of type 41 (SPAM_PV_THREAD) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "SpamPvThreadRequestModel" to this function
    ///
    /// Outputs:
    /// - It has 2 callbacks as responses. the las callback will come 3 times : for LeaveThread response, for BlockContact response, for ClearHistory response
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (SpamPvThreadRequestModel)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion: (response) it will returns the response that comes from server to this request for 3 times!. (Any as! ThreadModel) (Any as! BlockedContactModel) (Any as! ClearHistoryModel)
    public func spamPvThread(inputModel spamPvThreadInput: SpamPvThreadRequestModel,
                             uniqueId:          @escaping (String) -> (),
                             completions:       @escaping callbackTypeAlias) {
        
        log.verbose("Try to request to spam thread with this parameters: \n \(spamPvThreadInput)", context: "Chat")
        uniqueId(spamPvThreadInput.uniqueId)
        
        spamPvThreadCallbackToUser = completions
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.SPAM_PV_THREAD.rawValue,
                                            content:            nil,
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
                                callbacks:          [(SpamPvThread(), spamPvThreadInput.uniqueId)],
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil)
    }
    
    
    // MARK: - Mute/Unmute Thread
    
    /// MuteThread:
    /// mute a thread
    ///
    /// By calling this function, a request of type 19 (MUTE_THREAD) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "MuteAndUnmuteThreadRequestModel" to this function
    ///
    /// Outputs:
    /// - It has 2 callbacks as responses.
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (MuteAndUnmuteThreadRequestModel)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion: (response) it will returns the response that comes from server to this request. (Any as! MuteUnmuteThreadModel)
    public func muteThread(inputModel muteThreadInput: MuteAndUnmuteThreadRequestModel,
                           uniqueId:        @escaping (String) -> (),
                           completion:      @escaping callbackTypeAlias) {
        
        log.verbose("Try to request to mute threads with this parameters: \n \(muteThreadInput)", context: "Chat")
        uniqueId(muteThreadInput.uniqueId)
        
        muteThreadCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.MUTE_THREAD.rawValue,
                                            content:            nil,
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
    
    
    /// UnmuteThread:
    /// unmute a thread
    ///
    /// By calling this function, a request of type 20 (UNMUTE_THREAD) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "MuteAndUnmuteThreadRequestModel" to this function
    ///
    /// Outputs:
    /// - It has 2 callbacks as responses.
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (MuteAndUnmuteThreadRequestModel)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion: (response) it will returns the response that comes from server to this request. (Any as! MuteUnmuteThreadModel)
    public func unmuteThread(inputModel unmuteThreadInput: MuteAndUnmuteThreadRequestModel,
                             uniqueId:          @escaping (String) -> (),
                             completion:        @escaping callbackTypeAlias) {
        
        log.verbose("Try to request to unmute threads with this parameters: \n \(unmuteThreadInput)", context: "Chat")
        uniqueId(unmuteThreadInput.uniqueId)
        
        unmuteThreadCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.UNMUTE_THREAD.rawValue,
                                            content:            nil,
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
    
    
    // MARK: - Get/Add/Remove ThreadParticipants
    
    /// GetThreadParticipants:
    /// get all participants in a specific thread.
    ///
    /// By calling this function, a request of type 27 (THREAD_PARTICIPANTS) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "GetThreadParticipantsRequestModel" to this function
    ///
    /// Outputs:
    /// - It has 3 callbacks as responses.
    ///
    /// - parameter inputModel:     (input) you have to send your parameters insid this model. (GetThreadParticipantsRequestModel)
    /// - parameter uniqueId:       (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion:     (response) it will returns the response that comes from server to this request. (Any as! GetThreadParticipantsModel)
    /// - parameter cacheResponse:  (response) there is another response that comes from CacheDB to the user, if user has set 'enableCache' vaiable to be true. (GetThreadParticipantsModel)
    public func getThreadParticipants(inputModel getThreadParticipantsInput:   GetThreadParticipantsRequestModel,
                                      uniqueId:                     @escaping (String) -> (),
                                      completion:                   @escaping callbackTypeAlias,
                                      cacheResponse:                @escaping (GetThreadParticipantsModel) -> ()) {
        
        log.verbose("Try to request to get thread participants with this parameters: \n \(getThreadParticipantsInput)", context: "Chat")
        uniqueId(getThreadParticipantsInput.uniqueId)
        
        threadParticipantsCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.THREAD_PARTICIPANTS.rawValue,
                                            content:            "\(getThreadParticipantsInput.convertContentToJSON())",
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          getThreadParticipantsInput.threadId,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           getThreadParticipantsInput.typeCode ?? generalTypeCode,
                                            uniqueId:           getThreadParticipantsInput.uniqueId,
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: true)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  nil)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callbacks:          [(GetThreadParticipantsCallbacks(parameters: chatMessage), getThreadParticipantsInput.uniqueId)],
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil)
        
        // if cache is enabled by user, it will return cache result to the user
        if enableCache {
            if let cacheThreadParticipants = Chat.cacheDB.retrieveThreadParticipants(admin:     getThreadParticipantsInput.admin,
                                                                                     ascending: true,
                                                                                     count:     getThreadParticipantsInput.count ?? 50,
                                                                                     offset:    getThreadParticipantsInput.offset ?? 0,
                                                                                     threadId:  getThreadParticipantsInput.threadId,
                                                                                     timeStamp: cacheTimeStamp) {
                cacheResponse(cacheThreadParticipants)
            }
        }
        
    }
    
    
    /// AddParticipants:
    /// add participant to a specific thread.
    ///
    /// By calling this function, a request of type 11 (ADD_PARTICIPANT) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "AddParticipantsRequestModel" to this function
    ///
    /// Outputs:
    /// - It has 2 callbacks as responses.
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (AddParticipantsRequestModel)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion: (response) it will returns the response that comes from server to this request. (Any as! AddParticipantModel)
    public func addParticipants(inputModel addParticipantsInput:   AddParticipantsRequestModel,
                                uniqueId:               @escaping (String) -> (),
                                completion:             @escaping callbackTypeAlias) {
        log.verbose("Try to request to add participants with this parameters: \n \(addParticipantsInput)", context: "Chat")
        uniqueId(addParticipantsInput.uniqueId)
        
        addParticipantsCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.ADD_PARTICIPANT.rawValue,
                                            content:            "\(addParticipantsInput.contacts)",
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          addParticipantsInput.threadId,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           addParticipantsInput.typeCode ?? generalTypeCode,
                                            uniqueId:           addParticipantsInput.uniqueId,
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: true)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  nil)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callbacks:          [(AddParticipantsCallback(parameters: chatMessage), addParticipantsInput.uniqueId)],
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil)
    }
    
    
    /// RemoveParticipants:
    /// remove participants from a specific thread.
    ///
    /// By calling this function, a request of type 18 (REMOVE_PARTICIPANT) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "RemoveParticipantsRequestModel" to this function
    ///
    /// Outputs:
    /// - It has 2 callbacks as responses.
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (RemoveParticipantsRequestModel)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion: (response) it will returns the response that comes from server to this request. (Any as! RemoveParticipantModel)
    public func removeParticipants(inputModel removeParticipantsInput: RemoveParticipantsRequestModel,
                                   uniqueId:                @escaping (String) -> (),
                                   completion:              @escaping callbackTypeAlias) {
        log.verbose("Try to request to remove participants with this parameters: \n \(removeParticipantsInput)", context: "Chat")
        uniqueId(removeParticipantsInput.uniqueId)
        
        removeParticipantsCallbackToUser = completion
 
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.REMOVE_PARTICIPANT.rawValue,
                                            content:            "\(removeParticipantsInput.participantIds)",
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          removeParticipantsInput.threadId,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           removeParticipantsInput.typeCode ?? generalTypeCode,
                                            uniqueId:           removeParticipantsInput.uniqueId,
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: true)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  nil)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callbacks:          [(RemoveParticipantsCallback(parameters: chatMessage), removeParticipantsInput.uniqueId)],
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil)
    }
    
    
    
    // MARK: - Get/Set/Remove AdminRole
    
    /// SetRole:
    /// set role to User
    ///
    /// By calling this function, a request of type 42 (SET_RULE_TO_USER) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "RoleRequestModel" to this function
    ///
    /// Outputs:
    /// - It has 3 callbacks as responses.
    ///
    /// - parameter inputModel:     (input) you have to send your parameters insid this model. (RoleRequestModel)
    /// - parameter uniqueId:       (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion:     (response) it will returns the response that comes from server to this request. (Any as! UserRolesModel)
    /// - parameter cacheResponse:  (response) there is another response that comes from CacheDB to the user, if user has set 'enableCache' vaiable to be true. (UserRolesModel)
    public func setRole(inputModel setRoleInput: RoleRequestModel,
                        uniqueId:       @escaping (String) -> (),
                        completion:     @escaping callbackTypeAlias) {
        
        uniqueId(setRoleInput.uniqueId)
        setRoleToUserCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.SET_RULE_TO_USER.rawValue,
                                            content:            "\(setRoleInput.convertContentToJSON())",
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          setRoleInput.threadId,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           setRoleInput.typeCode ?? generalTypeCode,
                                            uniqueId:           setRoleInput.uniqueId,
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: true)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  nil)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callbacks:          [(SetRoleToUserCallback(parameters: chatMessage), setRoleInput.uniqueId)],
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil)
    }
    
    
    
    /// RemoveRole:
    /// remove role from User
    ///
    /// By calling this function, a request of type 43 (REMOVE_RULE_FROM_USER) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "[RoleRequestModel]" to this function
    ///
    /// Outputs:
    /// - It has 3 callbacks as responses.
    ///
    /// - parameter inputModel:     (input) you have to send your parameters insid this model. ([RoleRequestModel])
    /// - parameter uniqueId:       (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion:     (response) it will returns the response that comes from server to this request. (Any as! UserRolesModel)
    /// - parameter cacheResponse:  (response) there is another response that comes from CacheDB to the user, if user has set 'enableCache' vaiable to be true. (UserRolesModel)
    public func removeRole(inputModel removeRoleInput: RoleRequestModel,
                           uniqueId:        @escaping (String) -> (),
                           completion:      @escaping callbackTypeAlias) {

        uniqueId(removeRoleInput.uniqueId)
        removeRoleFromUserCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.REMOVE_ROLE_FROM_USER.rawValue,
                                            content:            "\(removeRoleInput.convertContentToJSON())",
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          removeRoleInput.threadId,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           removeRoleInput.typeCode ?? generalTypeCode,
                                            uniqueId:           removeRoleInput.uniqueId,
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: true)

        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  nil)

        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callbacks:          [(SetRoleToUserCallback(parameters: chatMessage), removeRoleInput.uniqueId)],
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil)
    }
    
    
    /// setAuditor:
    /// setRoleTo a User on a peer to peer thread
    ///
    /// By calling this function, a request of type 42 (SET_RULE_TO_USER) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "AddRemoveAuditorRequestModel" to this function
    ///
    /// Outputs:
    /// - It has 3 callbacks as responses.
    ///
    /// - parameter inputModel:     (input) you have to send your parameters insid this model. (AddRemoveAuditorRequestModel)
    /// - parameter uniqueId:       (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion:     (response) it will returns the response that comes from server to this request. (Any as! UserRolesModel)
    /// - parameter cacheResponse:  (response) there is another response that comes from CacheDB to the user, if user has set 'enableCache' vaiable to be true. (UserRolesModel)
    public func setAuditor(inputModel setAuditorInput:  AddRemoveAuditorRequestModel,
                           uniqueId:        @escaping (String) -> (),
                           completion:      @escaping callbackTypeAlias) {
        
        let setRoleModel = SetRemoveRoleModel(userId:   setAuditorInput.userId,
                                              roles:    setAuditorInput.roles)
        let setRoleInputModel = RoleRequestModel(userRoles: [setRoleModel],
                                                 threadId:  setAuditorInput.threadId,
                                                 typeCode:  setAuditorInput.typeCode,
                                                 uniqueId:  setAuditorInput.uniqueId)
        
        setRole(inputModel: setRoleInputModel, uniqueId: { (setRoleUniqueId) in
            uniqueId(setRoleUniqueId)
        }, completion: { (theServerResponse) in
            completion(theServerResponse)
        })
    }
    
    
    
    /// removeAuditorFromThread:
    /// removeRole From a User on a peer to peer thread
    ///
    /// By calling this function, a request of type 42 (SET_RULE_TO_USER) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "AddRemoveAuditorRequestModel" to this function
    ///
    /// Outputs:
    /// - It has 3 callbacks as responses.
    ///
    /// - parameter inputModel:     (input) you have to send your parameters insid this model. (AddRemoveAuditorRequestModel)
    /// - parameter uniqueId:       (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion:     (response) it will returns the response that comes from server to this request. (Any as! UserRolesModel)
    /// - parameter cacheResponse:  (response) there is another response that comes from CacheDB to the user, if user has set 'enableCache' vaiable to be true. (UserRolesModel)
    public func removeAuditor(inputModel removeAuditorInput:    AddRemoveAuditorRequestModel,
                              uniqueId:       @escaping (String) -> (),
                              completion:     @escaping callbackTypeAlias) {
        
        let removeRoleModel = SetRemoveRoleModel(userId:    removeAuditorInput.userId,
                                                 roles:     removeAuditorInput.roles)
        let removeRoleInputModel = RoleRequestModel(userRoles:  [removeRoleModel],
                                                    threadId:   removeAuditorInput.threadId,
                                                    typeCode:   removeAuditorInput.typeCode,
                                                    uniqueId:   removeAuditorInput.uniqueId)
        
        removeRole(inputModel: removeRoleInputModel, uniqueId: { (removeRoleUniqueId) in
            uniqueId(removeRoleUniqueId)
        }, completion: { (theServerResponse) in
            completion(theServerResponse)
        })
        
    }
    
    
    
    // MARK: - Pin/Unpin Thread
    
    /// PinThread:
    /// pin a thread
    ///
    /// By calling this function, a request of type 48 (PIN_THREAD) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "PinAndUnpinThreadRequestModel" to this function
    ///
    /// Outputs:
    /// - It has 2 callbacks as responses.
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (PinAndUnpinThreadRequestModel)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion: (response) it will returns the response that comes from server to this request. (Any as! PinUnpinThreadModel)
    public func pinThread(inputModel pinThreadInput: PinAndUnpinThreadRequestModel,
                           uniqueId:        @escaping (String) -> (),
                           completion:      @escaping callbackTypeAlias) {
        
        log.verbose("Try to request to pin threads with this parameters: \n \(pinThreadInput)", context: "Chat")
        uniqueId(pinThreadInput.uniqueId)
        
        pinThreadCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.PIN_THREAD.rawValue,
                                            content:            nil,
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
    
    
    /// UnpinThread:
    /// unpin a thread
    ///
    /// By calling this function, a request of type 49 (UNPIN_THREAD) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "PinAndUnpinThreadRequestModel" to this function
    ///
    /// Outputs:
    /// - It has 2 callbacks as responses.
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (PinAndUnpinThreadRequestModel)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion: (response) it will returns the response that comes from server to this request. (Any as! PinUnpinThreadModel)
    public func unpinThread(inputModel unpinThreadInput: PinAndUnpinThreadRequestModel,
                             uniqueId:          @escaping (String) -> (),
                             completion:        @escaping callbackTypeAlias) {
        
        log.verbose("Try to request to unpin threads with this parameters: \n \(unpinThreadInput)", context: "Chat")
        uniqueId(unpinThreadInput.uniqueId)
        
        unpinThreadCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.UNPIN_THREAD.rawValue,
                                            content:            nil,
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
    
    
    // MARK: - Seen Duration
    
    /// NotSeenDuration:
    /// contact not seen duration time
    ///
    /// By calling this function, a request of type 47 (GET_NOT_SEEN_DURATION) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "NotSeenDurationRequestModel" to this function
    ///
    /// Outputs:
    /// - It has 2 callbacks as responses.
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (NotSeenDurationRequestModel)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion: (response) it will returns the response that comes from server to this request. (Any as! NotSeenDurationModel)
    public func contactNotSeenDuration(inputModel notSeenDurationInput: NotSeenDurationRequestModel,
                             uniqueId:          @escaping (String) -> (),
                             completion:        @escaping callbackTypeAlias) {
        
        log.verbose("Try to request to get  user notSeenDuration with this parameters: \n \(notSeenDurationInput)", context: "Chat")
        uniqueId(notSeenDurationInput.uniqueId)
        
        getNotSeenDurationCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.GET_NOT_SEEN_DURATION.rawValue,
                                            content:            "\(notSeenDurationInput.convertContentToJSON())",
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          nil,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           notSeenDurationInput.typeCode ?? generalTypeCode,
                                            uniqueId:           notSeenDurationInput.uniqueId,
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: true)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  nil)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callbacks:          [(NotSeenDurationCallback(), notSeenDurationInput.uniqueId)],
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil)
    }
    
    
    
}


