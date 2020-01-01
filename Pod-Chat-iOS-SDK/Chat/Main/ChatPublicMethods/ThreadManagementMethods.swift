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
                                callback:           GetThreadsCallbacks(parameters: chatMessage),
                                callbacks:          nil,
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil,
                                uniuqueIdCallback:  nil)
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
                                            uniqueId:           getThreadsInput.uniqueId ?? generateUUID(),
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: nil)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  nil)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callback:           GetThreadsCallbacks(parameters: chatMessage),
                                callbacks:          nil,
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil) { (getThreadUniqueId) in
            uniqueId(getThreadUniqueId)
        }
        
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
                                            uniqueId:           updateThreadInfoInput.uniqueId ?? generateUUID(),
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: nil)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  nil)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callback:           UpdateThreadInfoCallback(),
                                callbacks:          nil,
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil) { (updateThreadInfoUniqueId) in
            uniqueId(updateThreadInfoUniqueId)
        }
        
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
                                            uniqueId:           createThreadInput.uniqueId ?? generateUUID(),
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: nil)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  nil)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callback:           CreateThreadCallback(parameters: chatMessage),
                                callbacks:          nil,
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil) { (createThreadUniqueId) in
            uniqueId(createThreadUniqueId)
        }
        
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
                                        uniqueId:                    @escaping (String) -> (),
                                        completion:                  @escaping callbackTypeAlias,
                                        onSent:                      @escaping callbackTypeAlias,
                                        onDelivere:                  @escaping callbackTypeAlias,
                                        onSeen:                      @escaping callbackTypeAlias) {
        
        log.verbose("Try to request to create thread and Send Message participants with this parameters: \n \(creatThreadWithMessageInput)", context: "Chat")
        
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
                                callback:           CreateThreadCallback(parameters: chatMessage),
                                callbacks:          nil,
                                sentCallback:       SendMessageCallbacks(parameters: chatMessage),
                                deliverCallback:    SendMessageCallbacks(parameters: chatMessage),
                                seenCallback:       SendMessageCallbacks(parameters: chatMessage)) { (theUniqueId) in
                                    uniqueId(theUniqueId)
        }
        
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
        
        let threadMessageUniqueId = creatThreadWithFileMessageInput.creatThreadWithMessageInput.createThreadInput.uniqueId ?? generateUUID()
        uniqueId(threadMessageUniqueId)
        
        /**
         seve this message on the Cache Wait Queue,
         so if there was an situation that response of the server to this message doesn't come, then we know that our message didn't sent correctly
         and we will send this Queue to user on the GetHistory request,
         now user knows which messages didn't send correctly, and can handle them
         */
//        if enableCache {
//            let messageObjectToSendToQueue = QueueOfWaitFileMessagesModel(content:      creatThreadWithFileMessageInput.content,
//                                                                          fileName:     creatThreadWithFileMessageInput.fileName,
//                                                                          imageName:    creatThreadWithFileMessageInput.imageName,
//                                                                          metadata:     (creatThreadWithFileMessageInput.metadata != nil) ? "\(creatThreadWithFileMessageInput.metadata!)" : nil,
//                                                                          repliedTo:    creatThreadWithFileMessageInput.repliedTo,
//                                                                          threadId:     creatThreadWithFileMessageInput.threadId,
//                                                                          xC:           creatThreadWithFileMessageInput.xC,
//                                                                          yC:           creatThreadWithFileMessageInput.yC,
//                                                                          hC:           creatThreadWithFileMessageInput.hC,
//                                                                          wC:           creatThreadWithFileMessageInput.wC,
//                                                                          fileToSend:   creatThreadWithFileMessageInput.fileToSend,
//                                                                          imageToSend:  creatThreadWithFileMessageInput.imageToSend,
//                                                                          typeCode:     creatThreadWithFileMessageInput.typeCode,
//                                                                          uniqueId:     messageUniqueId)
//            Chat.cacheDB.saveFileMessageToWaitQueue(fileMessage: messageObjectToSendToQueue)
//        }
        
        var fileExtension:  String  = ""
        let uploadUniqueId = generateUUID()
        
        var metadata: JSON = [:]
        
        if let imageInputs = creatThreadWithFileMessageInput.uploadImageInput {
            let uploadRequest = UploadImageRequestModel(dataToSend:         imageInputs.dataToSend,
                                                        fileExtension:      fileExtension,
                                                        fileName:           imageInputs.fileName,
                                                        originalFileName:   imageInputs.originalFileName,
                                                        threadId:           imageInputs.threadId,
                                                        xC:                 imageInputs.xC,
                                                        yC:                 imageInputs.yC,
                                                        hC:                 imageInputs.hC,
                                                        wC:                 imageInputs.wC,
                                                        typeCode:           nil,
                                                        uniqueId:           uploadUniqueId)
            
            metadata["file"]["originalName"] = JSON(uploadRequest.originalFileName)
            metadata["file"]["mimeType"]    = JSON("")
            metadata["file"]["size"]        = JSON(uploadRequest.fileSize)
            
            uploadImage(inputModel: uploadRequest,
                        uniqueId: { _ in },
                        progress: { (progress) in
                            uploadProgress(progress)
            }) { (response) in
                let myResponse: UploadImageModel = response as! UploadImageModel
                let link = "\(self.SERVICE_ADDRESSES.FILESERVER_ADDRESS)\(SERVICES_PATH.GET_IMAGE.rawValue)?imageId=\(myResponse.uploadImage!.id)&hashCode=\(myResponse.uploadImage!.hashCode)"
                
                var imageMetadata : JSON = [:]
                imageMetadata["link"]            = JSON(link)
                imageMetadata["id"]              = JSON(myResponse.uploadImage!.id)
                imageMetadata["name"]            = JSON(myResponse.uploadImage!.name ?? "")
                imageMetadata["height"]          = JSON(myResponse.uploadImage!.height ?? 0)
                imageMetadata["width"]           = JSON(myResponse.uploadImage!.width ?? 0)
                imageMetadata["actualHeight"]    = JSON(myResponse.uploadImage!.actualHeight ?? 0)
                imageMetadata["actualWidth"]     = JSON(myResponse.uploadImage!.actualWidth ?? 0)
                imageMetadata["hashCode"]        = JSON(myResponse.uploadImage!.hashCode)
                metadata["file"] = imageMetadata
                
                createThreadAndSendMessage(withMetadata: metadata)
            }
            
        } else if let fileInputs = creatThreadWithFileMessageInput.uploadfileInput {
            let uploadRequest = UploadFileRequestModel(dataToSend:      fileInputs.dataToSend,
                                                       fileExtension:   fileExtension,
                                                       fileName:        fileInputs.fileName,
                                                       originalFileName: fileInputs.originalFileName,
                                                       threadId:        fileInputs.threadId,
                                                       typeCode:        nil,
                                                       uniqueId:        uploadUniqueId)
            
            metadata["file"]["originalName"] = JSON(uploadRequest.originalFileName)
            metadata["file"]["mimeType"]    = JSON("")
            metadata["file"]["size"]        = JSON(uploadRequest.fileSize)
            
            uploadFile(inputModel: uploadRequest,
                       uniqueId: { _ in }, progress: { (progress) in
                uploadProgress(progress)
            }) { (response) in
                let myResponse: UploadFileModel = response as! UploadFileModel
                let link = "\(self.SERVICE_ADDRESSES.FILESERVER_ADDRESS)\(SERVICES_PATH.GET_FILE.rawValue)?fileId=\(myResponse.uploadFile!.id)&hashCode=\(myResponse.uploadFile!.hashCode)"
                
                var fileMetadata : JSON = [:]
                fileMetadata["link"]        = JSON(link)
                fileMetadata["id"]          = JSON(myResponse.uploadFile!.id)
                fileMetadata["name"]        = JSON(myResponse.uploadFile!.name ?? "")
                fileMetadata["hashCode"]    = JSON(myResponse.uploadFile!.hashCode)
                metadata["file"]    = fileMetadata
                
                createThreadAndSendMessage(withMetadata: metadata)
            }
            
        }
        
        // if there was no data to send, then returns an error to user
        if (creatThreadWithFileMessageInput.uploadfileInput?.dataToSend == nil) && (creatThreadWithFileMessageInput.uploadImageInput?.dataToSend == nil) {
            delegate?.chatError(errorCode:      6302,
                                errorMessage:   CHAT_ERRORS.err6302.rawValue,
                                errorResult:    nil)
        }
        
        
        // this will call when all data were uploaded and it will sends the textMessage
        func createThreadAndSendMessage(withMetadata: JSON) {
//            let messageInput = MessageInput(forwardedMessageIds: creatThreadWithFileMessageInput.creatThreadWithMessageInput.message?.forwardedMessageIds,
//                                            repliedTo:          creatThreadWithFileMessageInput.creatThreadWithMessageInput.message?.repliedTo,
//                                            text:               creatThreadWithFileMessageInput.creatThreadWithMessageInput.message?.text,
//                                            type:               creatThreadWithFileMessageInput.creatThreadWithMessageInput.message?.type,
//                                            metadata:           withMetadata,
//                                            systemMetadata:     creatThreadWithFileMessageInput.creatThreadWithMessageInput.message?.systemMetadata,
//                                            uniqueId:           creatThreadWithFileMessageInput.creatThreadWithMessageInput.message?.uniqueId)
//
//            let createThreadSendMessageParamModel = CreateThreadWithMessageRequestModel(description: creatThreadWithFileMessageInput.creatThreadWithMessageInput.description,
//                                                                                        image:      creatThreadWithFileMessageInput.creatThreadWithMessageInput.image,
//                                                                                        invitees:   creatThreadWithFileMessageInput.creatThreadWithMessageInput.invitees,
//                                                                                        metadata:   creatThreadWithFileMessageInput.creatThreadWithMessageInput.metadata,
//                                                                                        title:      creatThreadWithFileMessageInput.creatThreadWithMessageInput.title,
//                                                                                        type:       creatThreadWithFileMessageInput.creatThreadWithMessageInput.type,
//                                                                                        message:    messageInput,
//                                                                                        typeCode:   creatThreadWithFileMessageInput.creatThreadWithMessageInput.typeCode ?? generalTypeCode,
//                                                                                        uniqueId:   threadMessageUniqueId)
            
            let createThreadSendMessageParamModel = CreateThreadWithMessageRequestModel(createThreadInput: creatThreadWithFileMessageInput.creatThreadWithMessageInput.createThreadInput,
                                                                                        sendMessageInput: creatThreadWithFileMessageInput.creatThreadWithMessageInput.sendMessageInput)
            createThreadSendMessageParamModel.sendMessageInput?.metadata = withMetadata
            
            self.createThreadWithMessage(inputModel: createThreadSendMessageParamModel, uniqueId: { _ in }, completion: { (createThreadResponse) in
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
                                            uniqueId:           leaveThreadInput.uniqueId ?? generateUUID(),
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: true)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  nil)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callback:           LeaveThreadCallbacks(),
                                callbacks:          nil,
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil) { (leaveThreadUniqueId) in
            uniqueId(leaveThreadUniqueId)
        }
        
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
                                            uniqueId:           spamPvThreadInput.uniqueId ?? generateUUID(),
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: true)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  nil)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callback:           SpamPvThread(),
                                callbacks:          nil,
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil) { (spamUniqueId) in
            uniqueId(spamUniqueId)
        }
        
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
                                            uniqueId:           muteThreadInput.uniqueId ?? generateUUID(),
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: true)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  nil)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callback:           MuteThreadCallbacks(),
                                callbacks:          nil,
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil) { (muteThreadUniqueId) in
            uniqueId(muteThreadUniqueId)
        }
        
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
                                            uniqueId:           unmuteThreadInput.uniqueId ?? generateUUID(),
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: true)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  nil)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callback:           UnmuteThreadCallbacks(),
                                callbacks:          nil,
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil) { (muteThreadUniqueId) in
            uniqueId(muteThreadUniqueId)
        }
        
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
                                            uniqueId:           getThreadParticipantsInput.uniqueId ?? generateUUID(),
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: true)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  nil)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callback:           GetThreadParticipantsCallbacks(parameters: chatMessage),
                                callbacks:          nil,
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil) { (getParticipantsUniqueId) in
            uniqueId(getParticipantsUniqueId)
        }
        
        // if cache is enabled by user, it will return cache result to the user
        if enableCache {
            if let cacheThreadParticipants = Chat.cacheDB.retrieveThreadParticipants(admin:     getThreadParticipantsInput.admin,
                                                                                     ascending: true,
                                                                                     count:     getThreadParticipantsInput.count ?? 0,
                                                                                     offset:    getThreadParticipantsInput.offset ?? 50,
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
        /**
         *
         */
        log.verbose("Try to request to add participants with this parameters: \n \(addParticipantsInput)", context: "Chat")
        
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
                                callback:           AddParticipantsCallback(parameters: chatMessage),
                                callbacks:          nil,
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil) { (addParticipantsUniqueId) in
            uniqueId(addParticipantsUniqueId)
        }
        
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
        /**
         *
         */
        log.verbose("Try to request to remove participants with this parameters: \n \(removeParticipantsInput)", context: "Chat")
        
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
                                callback:           RemoveParticipantsCallback(parameters: chatMessage),
                                callbacks:          nil,
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil) { (removeParticipantsUniqueId) in
            uniqueId(removeParticipantsUniqueId)
        }
        
    }
    
    
    
    // MARK: - Get/Set/Remove AdminRole
    
    /// SetRole:
    /// set role to User
    ///
    /// By calling this function, a request of type 42 (SET_RULE_TO_USER) will send throut Chat-SDK,
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
    public func setRole(inputModel setRoleInput:    [RoleRequestModel],
                        uniqueId:       @escaping (String) -> (),
                        completion:     @escaping callbackTypeAlias,
                        cacheResponse:  @escaping callbackTypeAlias) {
        
        setRoleToUserCallbackToUser = completion
        
        var content: [JSON] = []
        for item in setRoleInput {
            content.append(SetRemoveRoleRequestModel(roleRequestModel: item, roleOperation: RoleOperations.Add).convertContentToJSON())
        }
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.SET_RULE_TO_USER.rawValue,
                                            content:            "\(content)",
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          setRoleInput.first!.threadId,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           setRoleInput.first?.typeCode ?? generalTypeCode,
                                            uniqueId:           nil,
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: true)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  nil)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callback:           SetRoleToUserCallback(parameters: chatMessage),
                                callbacks:          nil,
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil) { (getAminListUniqueId) in
                                    uniqueId(getAminListUniqueId)
        }
        
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
    public func removeRole(inputModel removeRoleInput: [RoleRequestModel],
                           uniqueId:        @escaping (String) -> (),
                           completion:      @escaping callbackTypeAlias,
                           cacheResponse:   @escaping callbackTypeAlias) {
        
        removeRoleFromUserCallbackToUser = completion
        
        var content: [JSON] = []
        for item in removeRoleInput {
            content.append(SetRemoveRoleRequestModel(roleRequestModel: item, roleOperation: RoleOperations.Remove).convertContentToJSON())
        }
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.REMOVE_ROLE_FROM_USER.rawValue,
                                            content:            "\(content)",
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          removeRoleInput.first!.threadId,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           removeRoleInput.first?.typeCode ?? generalTypeCode,
                                            uniqueId:           nil,
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: true)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  nil)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callback:           SetRoleToUserCallback(parameters: chatMessage),
                                callbacks:          nil,
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil) { (getAminListUniqueId) in
                                    uniqueId(getAminListUniqueId)
        }
        
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
                           completion:      @escaping callbackTypeAlias,
                           cacheResponse:   @escaping callbackTypeAlias) {
        
        let setRoleInputModel = RoleRequestModel(roles:          setAuditorInput.roles,
                                                 threadId:       setAuditorInput.threadId,
                                                 userId:         setAuditorInput.userId,
                                                 typeCode:       setAuditorInput.typeCode,
                                                 uniqueId:       setAuditorInput.uniqueId)
        setRole(inputModel: [setRoleInputModel], uniqueId: { (setRoleUniqueId) in
            uniqueId(setRoleUniqueId)
        }, completion: { (theServerResponse) in
            completion(theServerResponse)
        }) { (theCacheResponse) in
            cacheResponse(theCacheResponse)
        }
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
                              completion:     @escaping callbackTypeAlias,
                              cacheResponse:  @escaping callbackTypeAlias) {

        let removeRoleInputModel = RoleRequestModel(roles:       removeAuditorInput.roles,
                                                    threadId:    removeAuditorInput.threadId,
                                                    userId:      removeAuditorInput.userId,
                                                    typeCode:    removeAuditorInput.typeCode,
                                                    uniqueId:    removeAuditorInput.uniqueId)
        removeRole(inputModel: [removeRoleInputModel], uniqueId: { (removeRoleUniqueId) in
            uniqueId(removeRoleUniqueId)
        }, completion: { (theServerResponse) in
            completion(theServerResponse)
        }) { (theCacheResponse) in
            cacheResponse(theCacheResponse)
        }
        
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
                                            uniqueId:           pinThreadInput.uniqueId ?? generateUUID(),
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: true)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  nil)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callback:           PinThreadCallbacks(),
                                callbacks:          nil,
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil) { (muteThreadUniqueId) in
            uniqueId(muteThreadUniqueId)
        }
        
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
                                            uniqueId:           unpinThreadInput.uniqueId ?? generateUUID(),
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: true)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  nil)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callback:           UnpinThreadCallbacks(),
                                callbacks:          nil,
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil) { (muteThreadUniqueId) in
            uniqueId(muteThreadUniqueId)
        }
        
    }
    
}


