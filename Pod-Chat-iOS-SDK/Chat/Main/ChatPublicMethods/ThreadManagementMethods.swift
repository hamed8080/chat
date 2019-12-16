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
                                            metaData:           nil,
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
                                            metaData:           nil,
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
                                            metaData:           nil,
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
                                            metaData:           nil,
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
                                            metaData:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          nil,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           creatThreadWithMessageInput.typeCode ?? generalTypeCode,
                                            uniqueId:           creatThreadWithMessageInput.uniqueId,
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
                                            metaData:           nil,
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
                                            metaData:           nil,
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
                                            metaData:           nil,
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
                                            metaData:           nil,
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
                                            metaData:           nil,
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
                                            metaData:           nil,
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
                                            metaData:           nil,
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
    /// setRoleTo or removeRoleFrom User
    ///
    /// By calling this function, a request of type 42 (SET_RULE_TO_USER) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "[SetRoleRequestModel]" to this function
    ///
    /// Outputs:
    /// - It has 3 callbacks as responses.
    ///
    /// - parameter inputModel:     (input) you have to send your parameters insid this model. ([SetRoleRequestModel])
    /// - parameter uniqueId:       (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion:     (response) it will returns the response that comes from server to this request. (Any as! UserRolesModel)
    /// - parameter cacheResponse:  (response) there is another response that comes from CacheDB to the user, if user has set 'enableCache' vaiable to be true. (UserRolesModel)
    public func setRole(inputModel setRoleInput:    [SetRoleRequestModel],
                        uniqueId:       @escaping (String) -> (),
                        completion:     @escaping callbackTypeAlias,
                        cacheResponse:  @escaping callbackTypeAlias) {
        
        setRoleToUserCallbackToUser = completion
        
        var content: [JSON] = []
        for item in setRoleInput {
            content.append(item.convertContentToJSON())
        }
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.SET_RULE_TO_USER.rawValue,
                                            content:            "\(content)",
                                            metaData:           nil,
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
    
        let setRoleInputModel = SetRoleRequestModel(roles:          setAuditorInput.roles,
                                                    roleOperation:  RoleOperations.Add,
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

        let setRoleInputModel = SetRoleRequestModel(roles:          removeAuditorInput.roles,
                                                    roleOperation:  RoleOperations.Remove,
                                                    threadId:       removeAuditorInput.threadId,
                                                    userId:         removeAuditorInput.userId,
                                                    typeCode:       removeAuditorInput.typeCode,
                                                    uniqueId:       removeAuditorInput.uniqueId)
        setRole(inputModel: [setRoleInputModel], uniqueId: { (setRoleUniqueId) in
            uniqueId(setRoleUniqueId)
        }, completion: { (theServerResponse) in
            completion(theServerResponse)
        }) { (theCacheResponse) in
            cacheResponse(theCacheResponse)
        }
        
    }
    
    
    
}


