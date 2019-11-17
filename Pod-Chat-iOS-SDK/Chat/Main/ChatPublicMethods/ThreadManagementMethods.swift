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
                                            typeCode:           input.requestTypeCode ?? generalTypeCode,
                                            uniqueId:           nil,
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
    
    /*
     GetThreads:
     By calling this function, a request of type 14 (GET_THREADS) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some optional prameters as an input, as 'GetThreadsRequestModel' Model
     - count:        how many thread do you want to get with this request.           (Int)       -optional-  , if you don't set it, it would have default value of 50
     - offset:       offset of the contact number that start to count to show.       (Int)       -optional-  , if you don't set it, it would have default value of 0
     - name:         if you want to search on your contact, put it here.             (String)    -optional-  ,
     - new:
     - threadIds:    this parameter gets an array of threadId to fileter the result. ([Int])     -optional-  ,
     - typeCode:
     
     + Outputs:
     It has 2 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- completion:  it will returns the response that comes from server to this request.    (GetThreadsModel)
     3- cacheResponse:  there is another response that comes from CacheDB to the user, if user has set 'enableCache' vaiable to be true
     */
    public func getThreads(getThreadsInput: GetThreadsRequestModel,
                           uniqueId:        @escaping (String) -> (),
                           completion:      @escaping callbackTypeAlias,
                           cacheResponse:   @escaping (GetThreadsModel) -> ()) {
        /*
         *  -> set the "completion" to the "threadsCallbackToUser" variable
         *      (when the expected answer comes from server, threadsCallbackToUser will call, and the "complition" of this func will execute)
         *  -> get getThreadsInput and create the content JSON of it:
         *      + content:
         *          - count:                Int
         *          - creatorCoreUserId:    Int?
         *          - metadataCriteria:     JSON?
         *          - name:                 String?
         *          - new:                  Bool?
         *          - offset:               Int
         *          - partnerCoreContactId: Int?
         *          - partnerCoreUserId:    Int??
         *          - threadIds             [Int]?
         *  -> convert the JSON content to String
         *  -> create "SendChatMessageVO" and put the String content inside its content
         *  -> create "SendAsyncMessageVO" and put "SendChatMessageVO" inside its content
         *  -> send the "SendAsyncMessageVO" to Async
         *  -> configure that when answer comes from server, "GetThreadsCallbacks()" is the responsable func to do the rest
         *  -> send a request to Cache and return the Cahce response on the "cacheResponse" callback
         *
         */
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
                                            typeCode:           getThreadsInput.requestTypeCode ?? generalTypeCode,
                                            uniqueId:           getThreadsInput.requestUniqueId ?? generateUUID(),
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
                                                               threadIds:   getThreadsInput.threadIds,
                                                               timeStamp:   cacheTimeStamp) {
                cacheResponse(cacheThreads)
            }
        }
        
    }
    
    
    /*
     UpdateThreadInfo:
     update information about a thread.
     
     By calling this function, a request of type 30 (UPDATE_THREAD_INFO) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some optional prameters as an input, as JSON or Model (depends on the function that you would use) which are:
     - subjectId:
     - image:
     - description:
     - title:
     - metadata:
     - typeCode:
     
     + Outputs:
     It has 2 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- completion:
     */
    public func updateThreadInfo(updateThreadInfoInput: UpdateThreadInfoRequestModel,
                                 uniqueId:              @escaping (String) -> (),
                                 completion:            @escaping callbackTypeAlias) {
        /*
         *  -> set the "completion" to the "updateThreadInfoCallbackToUser" variable
         *      (when the expected answer comes from server, updateThreadInfoCallbackToUser will call, and the "complition" of this func will execute)
         *  -> get updateThreadInfoInput and create the content JSON of it:
         *      + content:
         *          - image:        String?
         *          - description:  String?
         *          - name:         String?
         *          - metadata:     String?
         *          - title:        String?
         *  -> convert the JSON content to String
         *  -> create "SendChatMessageVO" and put the String content inside its content
         *  -> create "SendAsyncMessageVO" and put "SendChatMessageVO" inside its content
         *  -> send the "SendAsyncMessageVO" to Async
         *  -> configure that when answer comes from server, "UpdateThreadInfoCallback()" is the responsable func to do the rest
         *
         */
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
                                            typeCode:           updateThreadInfoInput.requestTypeCode ?? generalTypeCode,
                                            uniqueId:           updateThreadInfoInput.requestUniqueId ?? generateUUID(),
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
    
    /*
     * CreateThread:
     * create a thread with somebody
     *
     * By calling this function, a request of type 1 (CREATE_THREAD) will send throut Chat-SDK,
     * then the response will come back as callbacks to client whose calls this function.
     *
     *  + Access:   - Public
     *  + Inputs:
     *      + createThreadInput:    CreateThreadRequestModel
     *          - description:  String?
     *          - image:        String?
     *          + invitees:     [Invitee]   (this is also an Array that contains "Invitee" Model)
     *              [
     *              - id:       String?
     *              - idType:   Int?        (INVITEE_VO_ID_TYPES)
     *              ]
     *          - metadata:     String?
     *          - title:        String      (give a title to the thread that you are going to create)
     *          - type:         String?     (type of the thread that you are creating)
     *          - uniqueId:     String?
     *  + Outputs:
     *      It has 2 callbacks as response:
     *      - uniqueId:     it will returns the request 'UniqueId' that will send to server.        (String)
     *      - completion:   it will returns the response that comes from server to this request.    (ThreadModel)
     *
     */
    public func createThread(createThreadInput: CreateThreadRequestModel,
                             uniqueId:          @escaping (String) -> (),
                             completion:        @escaping callbackTypeAlias) {
        /*
         *  -> set the "completion" to the "createThreadCallbackToUser" variable
         *      (when the expected answer comes from server, createThreadCallbackToUser will call, and the "complition" of this func will execute)
         *  -> get createThreadInput and create the content JSON of it
         *  -> create "SendChatMessageVO" and put the JSON content inside its content
         *  -> create "SendAsyncMessageVO" and put "SendChatMessageVO" inside its content
         *  -> send the "SendAsyncMessageVO" to Async
         *  -> configure that when answer comes from server, "CreateThreadCallback()" is the responsable func to do the rest
         *
         */
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
                                            typeCode:           nil,
                                            uniqueId:           createThreadInput.requestUniqueId ?? generateUUID(),
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
    
    
    /*
     * CreateThreadAndSendMessage:
     * create a thread with somebody and simultaneously send a message on this thread.
     *
     * By calling this function, a request of type 1 (CREATE_THREAD) will send throut Chat-SDK,
     * then the response will come back as callbacks to client whose calls this function.
     *
     *  + Access:   - Public
     *  + Inputs:
     *      + creatThreadWithMessageInput:  CreateThreadWithMessageRequestModel
     *          - threadDescription:            String?
     *          - threadImage:                  String?
     *          + threadInvitees:               [Invitee]       (this is also an Array that contains "Invitee" Model)
     *              [
     *              - id:       String?
     *              - idType:   Int?                            (INVITEE_VO_ID_TYPES)
     *              ]
     *          - threadMetadata:               String?
     *          - threadTitle:                  String          (give a title to the thread that you are going to create)
     *          - threadType:                   ThreadTypes     (type of the thread that you are creating)
     *          - messageForwardedMessageIds:   String?
     *          - messageForwardedUniqueIds:    String?
     *          - messageMetaData:              String?
     *          - messageRepliedTo:             Int?
     *          - messageSystemMetaData:        String?
     *          - messageText:                  String          (content of the message (the text Message))
     *          - messageType:                  String?
     *          - uniqueId:                     String?
     *
     *  + Outputs:
     *      It has 5 callbacks as response:
     *      1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     *      2- completion:  it will returns the response that comes from server to this request.    (ThreadModel)
     *      3- onSent:      when this message has sent to the server, this response will come.
     *      4- onDelivere:  when this message has delivered to the user, this response will come.
     *      5- onSeen:      when the user has seen this message, this response will come.
     *
     */
    public func createThreadWithMessage(creatThreadWithMessageInput: CreateThreadWithMessageRequestModel,
                                        uniqueId:                    @escaping (String) -> (),
                                        completion:                  @escaping callbackTypeAlias,
                                        onSent:                      @escaping callbackTypeAlias,
                                        onDelivere:                  @escaping callbackTypeAlias,
                                        onSeen:                      @escaping callbackTypeAlias) {
        /*
         *  -> set the "completion" to the "createThreadCallbackToUser" variable
         *      (when the expected answer comes from server, createThreadCallbackToUser will call, and the "complition" of this func will execute)
         *  -> set the "onSent" to the "sendCallbackToUserOnSent" variable
         *  -> set the "onDelivere" to the "sendCallbackToUserOnDeliver" variable
         *  -> set the "onSeen" to the "sendCallbackToUserOnSeen" variable
         *  -> get creatThreadWithMessageInput and create the content JSON of it:
         *      + content:
         *          + message:      JSON
         *              - text:                 messageText                 (String)
         *              - type:                 messageType                 (String?)
         *              - metaData:             messageMetaData             (String?)
         *              - systemMetadata:       messageSystemMetaData       (String?)
         *              - repliedTo:            messageRepliedTo            (Int?)
         *              - forwardedMessageIds:  messageForwardedMessageIds  (String?)
         *              - forwardedUniqueIds:   messageForwardedUniqueIds   (String?)
         *              - uniqueId:             uniqueId                    (String)
         *          - uniqueId:         uniqueId            (String)
         *          - title:            threadTitle         (String)
         *          - invitees:         threadInvitees      ([JSON])
         *          - image:            threadImage         (String?)
         *          - metadata:         threadMetadata      (String?)
         *          - description:      threadDescription   (String?)
         *          - type:             threadType          (Int)
         *
         *  -> create "SendChatMessageVO" and put the JSON content inside its content
         *  -> create "SendAsyncMessageVO" and put "SendChatMessageVO" inside its content
         *  -> send the "SendAsyncMessageVO" to Async
         *  -> configure that when answer comes from server, "CreateThreadCallback()" is the responsable func to do the rest
         *
         */
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
                                            typeCode:           creatThreadWithMessageInput.requestTypeCode ?? generalTypeCode,
                                            uniqueId:           creatThreadWithMessageInput.requestUniqueId,
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
    /*
     LeaveThread:
     leave from a specific thread.
     
     By calling this function, a request of type 9 (LEAVE_THREAD) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some optional prameters as an input, as JSON or Model (depends on the function that you would use) which are:
     - threadId:     id of the thread that you want to remove some participant it.    (Int)
     - content:      array of participants in the thread to remove them.
     - uniqueId:
     - typeCode:
     
     + Outputs:
     It has 2 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- completion:  it will returns the response that comes from server to this request.    (ThreadModel)
     */
    public func leaveThread(leaveThreadInput:   LeaveThreadRequestModel,
                            uniqueId:           @escaping (String) -> (),
                            completion:         @escaping callbackTypeAlias) {
        /*
         *
         *
         *
         */
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
                                            typeCode:           leaveThreadInput.requestTypeCode ?? generalTypeCode,
                                            uniqueId:           leaveThreadInput.requestUniqueId ?? generateUUID(),
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
    
    
    /*
     SpamPVThread:
     spam a thread.
     
     By calling this function, a request of type 41 (SPAM_PV_THREAD) will send throut Chat-SDK,
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
    public func spamPvThread(spamPvThreadInput: SpamPvThreadRequestModel,
                             uniqueId:          @escaping (String) -> (),
                             completion:        @escaping callbackTypeAlias) {
        /*
         *
         *
         */
        log.verbose("Try to request to spam thread with this parameters: \n \(spamPvThreadInput)", context: "Chat")
        
        spamPvThreadCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.SPAM_PV_THREAD.rawValue,
                                            content:            nil,
                                            metaData:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          spamPvThreadInput.threadId,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           spamPvThreadInput.requestTypeCode ?? generalTypeCode,
                                            uniqueId:           nil,
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
    /*
     MuteThread:
     mute a thread
     
     By calling this function, a request of type 19 (MUTE_THREAD) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some optional prameters as an input, as JSON or Model (depends on the function that you would use) which are:
     - subjectId:   id of the thread that you want to mute it.    (Int)
     - typeCode:
     
     + Outputs:
     It has 2 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- completion:  it will returns the response that comes from server to this request.    (??)
     */
    public func muteThread(muteThreadInput: MuteAndUnmuteThreadRequestModel,
                           uniqueId:        @escaping (String) -> (),
                           completion:      @escaping callbackTypeAlias) {
        /*
         *
         *
         *
         */
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
                                            typeCode:           muteThreadInput.requestTypeCode ?? generalTypeCode,
                                            uniqueId:           nil,
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
    
    
    /*
     UnmuteThread:
     mute a thread
     
     By calling this function, a request of type 20 (UNMUTE_THREAD) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some optional prameters as an input, as JSON or Model (depends on the function that you would use) which are:
     - subjectId:   id of the thread that you want to mute it.    (Int)
     - typeCode:
     
     + Outputs:
     It has 2 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- completion:  it will returns the response that comes from server to this request.    (??)
     */
    public func unmuteThread(unmuteThreadInput: MuteAndUnmuteThreadRequestModel,
                             uniqueId:          @escaping (String) -> (),
                             completion:        @escaping callbackTypeAlias) {
        /*
         *
         *
         *
         */
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
                                            typeCode:           unmuteThreadInput.requestTypeCode ?? generalTypeCode,
                                            uniqueId:           nil,
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
    /*
     * GetThreadParticipants:
     * get all participants in a specific thread.
     *
     * By calling this function, a request of type 27 (THREAD_PARTICIPANTS) will send throut Chat-SDK,
     * then the response will come back as callbacks to client whose calls this function.
     *
     * + Inputs:
     * this function will get some optional prameters as an input, as JSON or Model (depends on the function that you would use) which are:
     * - threadId:    id of the thread that you want to mute it.    (Int)
     * - count:
     * - offset:
     * - firstMessageId:
     * - lastMessageId:
     * - name:
     * - typeCode:
     *
     * + Outputs:
     * It has 2 callbacks as response:
     * 1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     * 2- completion:  it will returns the response that comes from server to this request.    (GetThreadParticipantsModel)
     * 3- cacheResponse:  there is another response that comes from CacheDB to the user, if user has set 'enableCache' vaiable to be true
     */
    public func getThreadParticipants(getThreadParticipantsInput:   GetThreadParticipantsRequestModel,
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
                                            typeCode:           getThreadParticipantsInput.requestTypeCode ?? generalTypeCode,
                                            uniqueId:           nil,
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
    
    
    /*
     AddParticipants:
     add participant to a specific thread.
     
     By calling this function, a request of type 11 (ADD_PARTICIPANT) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some optional prameters as an input, as JSON or Model (depends on the function that you would use) which are:
     - threadId:     id of the thread that you want to add somebody to it.    (Int)
     - contacts:     array of contact ids to add them to this thread
     - uniqueId:
     - typeCode:
     
     + Outputs:
     It has 2 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- completion:  it will returns the response that comes from server to this request.    (AddParticipantModel)
     */
    public func addParticipants(addParticipantsInput:   AddParticipantsRequestModel,
                                uniqueId:               @escaping (String) -> (),
                                completion:             @escaping callbackTypeAlias) {
        /*
         *
         *
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
                                            typeCode:           addParticipantsInput.requestTypeCode ?? generalTypeCode,
                                            uniqueId:           addParticipantsInput.requestUniqueId,
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
    
    
    /*
     RemoveParticipants:
     remove participants from a specific thread.
     
     By calling this function, a request of type 18 (REMOVE_PARTICIPANT) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some optional prameters as an input, as JSON or Model (depends on the function that you would use) which are:
     - threadId:     id of the thread that you want to remove some participant it.    (Int)
     - content:      array of participants in the thread to remove them.
     - uniqueId:
     - typeCode:
     
     + Outputs:
     It has 2 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- completion:  it will returns the response that comes from server to this request.    (RemoveParticipantModel)
     */
    public func removeParticipants(removeParticipantsInput: RemoveParticipantsRequestModel,
                                   uniqueId:                @escaping (String) -> (),
                                   completion:              @escaping callbackTypeAlias) {
        /*
         *
         *
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
                                            typeCode:           removeParticipantsInput.requestTypeCode ?? generalTypeCode,
                                            uniqueId:           removeParticipantsInput.requestUniqueId,
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
    
    /*
    public func getAdminList(getAdminListInput: GetAdminListRequestModel,
                             uniqueId:          @escaping (String) -> (),
                             completion:        @escaping callbackTypeAlias,
                             cacheResponse:     @escaping callbackTypeAlias) {
        var content: JSON = [:]
        
        if let requestUniqueId = getAdminListInput.uniqueId {
            content["uniqueId"] = JSON(requestUniqueId)
        }
        
        let sendMessageGetAdminListParams: JSON = ["chatMessageVOType": chatMessageVOTypes.GET_THREAD_ADMINS.rawValue,
                                                   "content": content,
                                                   "subjectId": getAdminListInput.threadId]
        
        sendMessageWithCallback(params: sendMessageGetAdminListParams,
                                callback:       GetAdminListCallback(parameters: sendMessageGetAdminListParams),
                                callbacks:      nil,
                                sentCallback:   nil,
                                deliverCallback: nil,
                                seenCallback:   nil) { (getAminListUniqueId) in
                                    uniqueId(getAminListUniqueId)
        }
        
        getAdminListCallbackToUser = completion
    }
    */
    
    
    
    public func setRole(setRoleInput:   [SetRoleRequestModel],
                        uniqueId:       @escaping (String) -> (),
                        completion:     @escaping callbackTypeAlias,
                        cacheResponse:  @escaping callbackTypeAlias) {
        /*
         *
         *
         *
         */
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
                                            typeCode:           setRoleInput.first?.requestTypeCode ?? generalTypeCode,
                                            uniqueId:           nil,
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
    
    
}


