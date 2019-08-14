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
        
        let content: JSON = ["summary": input.summary]
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.GET_THREADS.rawValue,
                                            content:            "\(content)",
                                            metaData:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          nil,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           input.typeCode ?? generalTypeCode,
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
     this function will get some optional prameters as an input, as JSON or Model (depends on the function that you would use) which are:
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
        
        var content: JSON = [:]
        content["count"]    = JSON(getThreadsInput.count ?? 50)
        content["offset"]    = JSON(getThreadsInput.offset ?? 0)
        if let name = getThreadsInput.name {
            content["name"] = JSON(name)
        }
        if let new = getThreadsInput.new {
            content["new"] = JSON(new)
        }
        if let threadIds = getThreadsInput.threadIds {
            content["threadIds"] = JSON(threadIds)
        }
        if let coreUserId = getThreadsInput.creatorCoreUserId {
            content["creatorCoreUserId"] = JSON(coreUserId)
        }
        if let coreUserId = getThreadsInput.partnerCoreUserId {
            content["partnerCoreUserId"] = JSON(coreUserId)
        }
        if let coreUserId = getThreadsInput.partnerCoreContactId {
            content["partnerCoreContactId"] = JSON(coreUserId)
        }
        if let metadataCriteria = getThreadsInput.metadataCriteria {
            content["metadataCriteria"] = JSON(metadataCriteria)
        }
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.GET_THREADS.rawValue,
                                            content:            "\(content)",
                                            metaData:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          nil,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           getThreadsInput.typeCode ?? generalTypeCode,
                                            uniqueId:           getThreadsInput.uniqueId ?? generateUUID(),
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
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'GetThreadsRequestModel' to get the parameters, it'll use JSON
    /*
    public func getThreads(params: JSON?, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        log.verbose("Try to request to get threads with this parameters: \n \(params ?? "params is empty!")", context: "Chat")
        
        var myTypeCode: String = generalTypeCode
        
        var content: JSON = ["count": 50, "offset": 0]
        
        if let parameters = params {
            if let count = parameters["count"].int {
                if count > 0 {
                    content["count"] = JSON(count)
                }
            }
            
            if let offset = parameters["offset"].int {
                if offset > 0 {
                    content["offset"] = JSON(offset)
                }
            }
            
            if let name = parameters["name"].string {
                content["name"] = JSON(name)
            }
            
            if let new = parameters["new"].bool {
                content["new"] = JSON(new)
            }
            
            if let threadIds = parameters["threadIds"].arrayObject {
                content["threadIds"] = JSON(threadIds)
            }
            
            if let typeCode = parameters["typeCode"].string {
                myTypeCode = typeCode
            }
            
            if let metadataCriteria = parameters["metadataCriteria"].string {
                content["metadataCriteria"] = JSON(metadataCriteria)
            } else if (parameters["metadataCriteria"] != JSON.null) {
                content["metadataCriteria"] = parameters["metadataCriteria"]
            }
            
        }
        
        let sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.GET_THREADS.rawValue,
                                       "content": content,
                                       "typeCode": myTypeCode]
        
        sendMessageWithCallback(params:         sendMessageParams,
                                callback:       GetThreadsCallbacks(parameters: sendMessageParams),
                                callbacks:      nil,
                                sentCallback:   nil,
                                deliverCallback: nil,
                                seenCallback:   nil) { (getThreadUniqueId) in
            uniqueId(getThreadUniqueId)
        }
        threadsCallbackToUser = completion
    }
    */
    
    
    
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
        
        var content: JSON = [:]
        if let image = updateThreadInfoInput.image {
            content["image"] = JSON(image)
        }
        if let description = updateThreadInfoInput.description {
            content["description"] = JSON(description)
        }
        if let name = updateThreadInfoInput.title {
            content["name"] = JSON(name)
        }
        if let metadata = updateThreadInfoInput.metadata {
            let metadataStr = "\(metadata)"
            content["metadata"] = JSON(metadataStr)
        }
        if let title = updateThreadInfoInput.title {
            content["title"] = JSON(title)
        }
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.UPDATE_THREAD_INFO.rawValue,
                                            content:            "\(content)",
                                            metaData:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          updateThreadInfoInput.threadId,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           updateThreadInfoInput.typeCode ?? generalTypeCode,
                                            uniqueId:           updateThreadInfoInput.uniqueId ?? generateUUID(),
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
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'UpdateThreadInfoRequestModel' to get the parameters, it'll use JSON
    /*
    public func updateThreadInfo(params: JSON, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        log.verbose("Try to request to update thread info with this parameters: \n \(params)", context: "Chat")
        
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.UPDATE_THREAD_INFO.rawValue,
                                       "typeCode": params["typeCode"].string ?? generalTypeCode]
        
        if let threadId = params["subjectId"].int {
            sendMessageParams["threadId"] = JSON(threadId)
            sendMessageParams["subjectId"] = JSON(threadId)
            
        } else {
            delegate?.chatError(errorCode: 999, errorMessage: "Thread ID is required for Updating thread info!", errorResult: nil)
        }
        
        var content: JSON = [:]
        
        if let image = params["image"].string {
            content["image"] = JSON(image)
        }
        
        if let description = params["description"].string {
            content["description"] = JSON(description)
        }
        
        if let name = params["title"].string {
            content["name"] = JSON(name)
        }
        
        if let metadata = params["metadata"].string {
            content["metadata"] = JSON(metadata)
        } else if (params["metadata"] != JSON.null) {
            let metadata = params["metadata"]
            let metadataStr = "\(metadata)"
            content["metadata"] = JSON(metadataStr)
        }
        
        sendMessageParams["content"] = JSON("\(content)")
        
        sendMessageWithCallback(params:         sendMessageParams,
                                callback:       UpdateThreadInfoCallback(),
                                callbacks:      nil,
                                sentCallback:   nil,
                                deliverCallback: nil,
                                seenCallback:   nil) { (updateThreadInfoUniqueId) in
            uniqueId(updateThreadInfoUniqueId)
        }
        updateThreadInfoCallbackToUser = completion
    }
    */
    
    
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
     *              - idType:   Int?        (InviteeVOidTypes)
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
        
        var content: JSON = [:]
        content["title"] = JSON(createThreadInput.title)
        var inviteees = [JSON]()
        for item in createThreadInput.invitees {
            inviteees.append(item.formatToJSON())
        }
        content["invitees"] = JSON(inviteees)
        if let image = createThreadInput.image {
            content["image"] = JSON(image)
        }
        if let metaData = createThreadInput.metadata {
            content["metadata"] = JSON(metaData)
        }
        if let description = createThreadInput.description {
            content["description"] = JSON(description)
        }
        if let type = createThreadInput.type {
            var theType: Int = 0
            switch type {
            case ThreadTypes.NORMAL:        theType = 0
            case ThreadTypes.OWNER_GROUP:   theType = 1
            case ThreadTypes.PUBLIC_GROUP:  theType = 2
            case ThreadTypes.CHANNEL_GROUP: theType = 4
            case ThreadTypes.CHANNEL:       theType = 8
            default:
                log.error("not valid thread type on create thread", context: "Chat")
            }
            content["type"] = JSON(theType)
        }
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.CREATE_THREAD.rawValue,
                                            content:            "\(content)",
                                            metaData:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          nil,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           nil,
                                            uniqueId:           createThreadInput.uniqueId ?? generateUUID(),
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
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'CreateThreadRequestModel' to get the parameters, it'll use JSON
    /*
    public func createThread(params: JSON?, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        log.verbose("Try to request to create thread participants with this parameters: \n \(params ?? "params is empty")", context: "Chat")
        
        var content: JSON = [:]
        
        if let parameters = params {
            
            if let title = parameters["title"].string {
                content.appendIfDictionary(key: "title", json: JSON(title))
            }
            
            if let type = parameters["type"].string {
                var theType: Int = 0
                switch type {
                case ThreadTypes.NORMAL.rawValue:         theType = 0
                case ThreadTypes.OWNER_GROUP.rawValue:    theType = 1
                case ThreadTypes.PUBLIC_GROUP.rawValue:   theType = 2
                case ThreadTypes.CHANNEL_GROUP.rawValue:  theType = 4
                case ThreadTypes.CHANNEL.rawValue:        theType = 8
                default:
                    //                    print("not valid thread type on create thread")
                    log.error("not valid thread type on create thread", context: "Chat")
                }
                content.appendIfDictionary(key: "type", json: JSON(theType))
            }
            
            if let title = parameters["title"].string {
                content.appendIfDictionary(key: "title", json: JSON(title))
            }
            
            if let invitees = parameters["invitees"].array {
                content.appendIfDictionary(key: "invitees", json: JSON(invitees))
            }
        }
        
        let sendMessageCreateThreadParams: JSON = ["chatMessageVOType": chatMessageVOTypes.CREATE_THREAD.rawValue,
                                                   "content": content]
        sendMessageWithCallback(params:         sendMessageCreateThreadParams,
                                callback:       CreateThreadCallback(parameters: sendMessageCreateThreadParams),
                                callbacks:      nil,
                                sentCallback:   nil,
                                deliverCallback: nil,
                                seenCallback:   nil) { (createThreadUniqueId) in
            uniqueId(createThreadUniqueId)
        }
        
        createThreadCallbackToUser = completion
        
    }
    */
    
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
     *              - idType:   Int?                            (InviteeVOidTypes)
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
        
        let myUniqueId = creatThreadWithMessageInput.uniqueId ?? generateUUID()
        
        var messageContentParams: JSON = [:]
        messageContentParams["text"] = JSON(creatThreadWithMessageInput.messageText)
        if let type = creatThreadWithMessageInput.messageType {
            messageContentParams["type"] = JSON(type)
        }
        if let metaData = creatThreadWithMessageInput.messageMetaData {
            messageContentParams["metaData"] = JSON(metaData)
        }
        if let systemMetadata = creatThreadWithMessageInput.messageSystemMetaData {
            messageContentParams["systemMetadata"] = JSON(systemMetadata)
        }
        if let repliedTo = creatThreadWithMessageInput.messageRepliedTo {
            messageContentParams["repliedTo"] = JSON(repliedTo)
        }
        if let forwardedMessageIds = creatThreadWithMessageInput.messageForwardedMessageIds {
            messageContentParams["forwardedMessageIds"] = JSON(forwardedMessageIds)
        }
        if let forwardedUniqueIds = creatThreadWithMessageInput.messageForwardedUniqueIds {
            messageContentParams["forwardedUniqueIds"] = JSON(forwardedUniqueIds)
        }
        messageContentParams["uniqueId"] = JSON(myUniqueId)
        
        var myContent: JSON = [:]
        myContent["message"]    = JSON(messageContentParams)
        myContent["uniqueId"]   = JSON(myUniqueId)
        myContent["title"]      = JSON(creatThreadWithMessageInput.threadTitle)
        var inviteees = [JSON]()
        for item in creatThreadWithMessageInput.threadInvitees {
            inviteees.append(item.formatToJSON())
        }
        myContent["invitees"] = JSON(inviteees)
        if let image = creatThreadWithMessageInput.threadImage {
            myContent["image"] = JSON(image)
        }
        if let metaData = creatThreadWithMessageInput.threadMetadata {
            myContent["metadata"] = JSON(metaData)
        }
        if let description = creatThreadWithMessageInput.threadDescription {
            myContent["description"] = JSON(description)
        }
        let type = creatThreadWithMessageInput.threadType
        var theType: Int = 0
        switch type {
        case ThreadTypes.NORMAL:        theType = 0
        case ThreadTypes.OWNER_GROUP:   theType = 1
        case ThreadTypes.PUBLIC_GROUP:  theType = 2
        case ThreadTypes.CHANNEL_GROUP: theType = 4
        case ThreadTypes.CHANNEL:       theType = 8
        default:
            log.error("not valid thread type on create thread", context: "Chat")
        }
        myContent["type"] = JSON(theType)
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.CREATE_THREAD.rawValue,
                                            content:            "\(myContent)",
                                            metaData:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          nil,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           nil,
                                            uniqueId:           myUniqueId,
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
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'CreateThreadWithMessageRequestModel' to get the parameters, it'll use JSON
    /*
    public func createThreadWithMessage(params: JSON?, sendMessageParams: JSON, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias, onSent: @escaping callbackTypeAlias, onDelivere: @escaping callbackTypeAlias, onSeen: @escaping callbackTypeAlias) {
        log.verbose("Try to request to create thread and Send Message participants with this parameters: \n \(params ?? "params is empty")", context: "Chat")
        
        let myUniqueId = generateUUID()
        
        var messageContentParams: JSON = sendMessageParams
        messageContentParams["uniqueId"] = JSON(myUniqueId)
        
        var content: JSON = ["message": messageContentParams]
        
        if let parameters = params {
            
            content["uniqueId"] = JSON(myUniqueId)
            
            if let title = parameters["title"].string {
                content.appendIfDictionary(key: "title", json: JSON(title))
            }
            
            if let type = parameters["type"].string {
                var theType: Int = 0
                switch type {
                case ThreadTypes.NORMAL.rawValue: theType = 0
                case ThreadTypes.OWNER_GROUP.rawValue: theType = 1
                case ThreadTypes.PUBLIC_GROUP.rawValue: theType = 2
                case ThreadTypes.CHANNEL_GROUP.rawValue: theType = 4
                case ThreadTypes.CHANNEL.rawValue: theType = 8
                default:
                    //                    print("not valid thread type on create thread")
                    log.error("not valid thread type on create thread", context: "Chat")
                }
                content.appendIfDictionary(key: "type", json: JSON(theType))
            }
            
            if let title = parameters["title"].string {
                content.appendIfDictionary(key: "title", json: JSON(title))
            }
            
            if let invitees = parameters["invitees"].array {
                content.appendIfDictionary(key: "invitees", json: JSON(invitees))
            }
        }
        let sendMessageCreateThreadParams: JSON = ["chatMessageVOType": chatMessageVOTypes.CREATE_THREAD.rawValue,
                                                   "content": content,
                                                   "uniqueId": myUniqueId]
        
        sendMessageWithCallback(params:         sendMessageCreateThreadParams,
                                callback:       CreateThreadCallback(parameters: sendMessageCreateThreadParams),
                                callbacks:      nil,
                                sentCallback:   SendMessageCallbacks(parameters: sendMessageCreateThreadParams),
                                deliverCallback: SendMessageCallbacks(parameters: sendMessageCreateThreadParams),
                                seenCallback:   SendMessageCallbacks(parameters: sendMessageCreateThreadParams)) { (theUniqueId) in
            uniqueId(theUniqueId)
        }
        
        createThreadCallbackToUser = completion
        sendCallbackToUserOnSent = onSent
        sendCallbackToUserOnDeliver = onDelivere
        sendCallbackToUserOnSeen = onSeen
    }
    */
    
    
    // NOTE: This method will be deprecate
    // implement creating a thread and sending a message with it, handeled by this SDK (not server!)
    /*
    public func createThreadAndSendMessage(params: JSON?, sendMessageParams: JSON, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias, onSent: @escaping callbackTypeAlias, onDelivere: @escaping callbackTypeAlias, onSeen: @escaping callbackTypeAlias) {
        log.verbose("Try to request to create thread and Send Message participants with this parameters: \n \(params ?? "params is empty")", context: "Chat")
        
        var myUniqueId: String = ""
        createThread(params: params, uniqueId: { (createThreadUniqueId) in
            myUniqueId = createThreadUniqueId
            uniqueId(createThreadUniqueId)
        }) { (myCreateThreadResponse) in
     
            let myResponseModel: CreateThreadModel = myCreateThreadResponse as! CreateThreadModel
            let myResponseJSON: JSON = myResponseModel.returnDataAsJSON()
            
            var sendParams: JSON = sendMessageParams
            sendParams["uniqueId"] = JSON(myUniqueId)
            if let theId = myResponseJSON["result"]["thread"]["id"].int {
                sendParams["subjectId"] = JSON(theId)
            }
            
            self.sendTextMessage(params: sendParams, uniqueId: { _ in }, onSent: { (isSent) in
                onSent(isSent)
            }, onDelivere: { (isDeliver) in
                onDelivere(isDeliver)
            }, onSeen: { (isSeen) in
                onSeen(isSeen)
            })
            
        }
        
    }
    */
    
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
                                            typeCode:           leaveThreadInput.typeCode ?? generalTypeCode,
                                            uniqueId:           leaveThreadInput.uniqueId ?? generateUUID(),
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
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'LeaveThreadRequestModel' to get the parameters, it'll use JSON
    /*
    public func leaveThread(params: JSON, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        log.verbose("Try to request to leave thread with this parameters: \n \(params)", context: "Chat")
        
        /**
         * + LeaveThreadRequest    {object}
         *    - subjectId          {long}
         *    - uniqueId           {string}
         */
        
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.LEAVE_THREAD.rawValue,
                                       "typeCode": params["typeCode"].string ?? generalTypeCode]
        
        if let subjectId = params["threadId"].int {
            sendMessageParams["subjectId"] = JSON(subjectId)
        }
        
        sendMessageWithCallback(params: sendMessageParams,
                                callback: LeaveThreadCallbacks(),
                                callbacks: nil,
                                sentCallback: nil,
                                deliverCallback: nil,
                                seenCallback: nil) { (leaveThreadUniqueId) in
            uniqueId(leaveThreadUniqueId)
        }
        leaveThreadCallbackToUser = completion
    }
    */
    
    
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
                                            typeCode:           spamPvThreadInput.typeCode ?? generalTypeCode,
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
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'SpamPvThreadRequestModel' to get the parameters, it'll use JSON
    /*
    public func spamPvThread(params: JSON, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        log.verbose("Try to request to spam thread with this parameters: \n \(params)", context: "Chat")
        
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.SPAM_PV_THREAD.rawValue,
                                       "typeCode": params["typeCode"].string ?? generalTypeCode]
        
        if let subjectId = params["threadId"].int {
            sendMessageParams["subjectId"] = JSON(subjectId)
        }
        
        sendMessageWithCallback(params:         sendMessageParams,
                                callback:       SpamPvThread(),
                                callbacks:      nil,
                                sentCallback:   nil,
                                deliverCallback: nil,
                                seenCallback:   nil) { (spamUniqueId) in
            uniqueId(spamUniqueId)
        }
        spamPvThreadCallbackToUser = completion
    }
    */
    
    
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
                                            typeCode:           muteThreadInput.typeCode ?? generalTypeCode,
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
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'MuteAndUnmuteThreadRequestModel' to get the parameters, it'll use JSON
    /*
    public func muteThread(params: JSON, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        log.verbose("Try to request to mute threads with this parameters: \n \(params)", context: "Chat")
        
        let sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.MUTE_THREAD.rawValue,
                                       "typeCode": params["typeCode"].string ?? generalTypeCode,
                                       "subjectId": params["subjectId"].intValue]
        
        sendMessageWithCallback(params:         sendMessageParams,
                                callback:       MuteThreadCallbacks(),
                                callbacks:      nil,
                                sentCallback:   nil,
                                deliverCallback: nil,
                                seenCallback:   nil) { (muteThreadUniqueId) in
            uniqueId(muteThreadUniqueId)
        }
        muteThreadCallbackToUser = completion
    }
    */
    
    
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
                                            typeCode:           unmuteThreadInput.typeCode ?? generalTypeCode,
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
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'MuteAndUnmuteThreadRequestModel' to get the parameters, it'll use JSON
    /*
    public func unmuteThread(params: JSON, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        log.verbose("Try to request to unmute threads with this parameters: \n \(params)", context: "Chat")
        
        let sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.UNMUTE_THREAD.rawValue,
                                       "typeCode": params["typeCode"].string ?? generalTypeCode,
                                       "subjectId": params["subjectId"].intValue]
        
        sendMessageWithCallback(params:         sendMessageParams,
                                callback:       UnmuteThreadCallbacks(),
                                callbacks:      nil,
                                sentCallback:   nil,
                                deliverCallback: nil,
                                seenCallback:   nil) { (muteThreadUniqueId) in
            uniqueId(muteThreadUniqueId)
        }
        unmuteThreadCallbackToUser = completion
    }
    */
    
    
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
        
        var content: JSON = [:]
        content["count"]    = JSON(getThreadParticipantsInput.count ?? getHistoryCount)
        content["offset"]   = JSON(getThreadParticipantsInput.offset ?? 0)
        
        if let firstMessageId = getThreadParticipantsInput.firstMessageId {
            content["firstMessageId"]   = JSON(firstMessageId)
        }
        
        if let lastMessageId = getThreadParticipantsInput.lastMessageId {
            content["lastMessageId"]   = JSON(lastMessageId)
        }
        
        if let name = getThreadParticipantsInput.name {
            content["name"]   = JSON(name)
        }
        
        if let admin = getThreadParticipantsInput.admin {
            content["admin"]   = JSON(admin)
        }
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.THREAD_PARTICIPANTS.rawValue,
                                            content:            "\(content)",
                                            metaData:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          getThreadParticipantsInput.threadId,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           getThreadParticipantsInput.typeCode ?? generalTypeCode,
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
                                                                                     count:     content["count"].intValue,
                                                                                     offset:    content["offset"].intValue,
                                                                                     threadId:  getThreadParticipantsInput.threadId,
                                                                                     timeStamp: cacheTimeStamp) {
                cacheResponse(cacheThreadParticipants)
            }
        }
        
    }
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'GetThreadParticipantsRequestModel' to get the parameters, it'll use JSON
    /*
    public func getThreadParticipants(params: JSON?, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        log.verbose("Try to request to get thread participants with this parameters: \n \(params ?? "params is empty")", context: "Chat")
        
        var myTypeCode = generalTypeCode
        var content: JSON = ["count": getHistoryCount, "offset": 0]
        var subjectId: Int = 0
        
        if let parameters = params {
            
            if let subId = parameters["threadId"].int {
                subjectId = subId
            }
            
            if let count = parameters["count"].int {
                if count > 0 {
                    content["count"] = JSON(count)
                }
            }
            
            if let offset = parameters["offset"].int {
                if offset > 0 {
                    content["offset"] = JSON(offset)
                }
            }
            
            if let firstMessageId = parameters["firstMessageId"].int {
                if firstMessageId > 0 {
                    content["firstMessageId"] = JSON(firstMessageId)
                }
            }
            
            if let lastMessageId = parameters["lastMessageId"].int {
                if lastMessageId > 0 {
                    content["lastMessageId"] = JSON(lastMessageId)
                }
            }
            
            if let name = parameters["name"].string {
                content["name"] = JSON(name)
            }
            
            if let typeCode = parameters["typeCode"].string {
                myTypeCode = typeCode
            }
            
        }
        
        let sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.THREAD_PARTICIPANTS.rawValue,
                                       "typeCode": myTypeCode,
                                       "content": content,
                                       "subjectId": subjectId]
        sendMessageWithCallback(params:         sendMessageParams,
                                callback:       GetThreadParticipantsCallbacks(parameters: sendMessageParams),
                                callbacks:      nil,
                                sentCallback:   nil,
                                deliverCallback: nil,
                                seenCallback:   nil) { (getParticipantsUniqueId) in
            uniqueId(getParticipantsUniqueId)
        }
        threadParticipantsCallbackToUser = completion
    }
    */
    
    
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
                                            typeCode:           addParticipantsInput.typeCode ?? generalTypeCode,
                                            uniqueId:           addParticipantsInput.uniqueId,
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
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'AddParticipantsRequestModel' to get the parameters, it'll use JSON
    /*
    public func addParticipants(params: JSON?, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        log.verbose("Try to request to add participants with this parameters: \n \(params ?? "params is empty")", context: "Chat")
        
        /*
         * + AddParticipantsRequest   {object}
         *    - subjectId             {long}
         *    + content               {list} List of CONTACT IDs
         *       -id                  {long}
         *    - uniqueId              {string}
         */
        
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.ADD_PARTICIPANT.rawValue]
        
        if let parameters = params {
            
            if let threadId = parameters["threadId"].int {
                if (threadId > 0) {
                    sendMessageParams["subjectId"] = JSON(threadId)
                }
            }
            
            if let contacts = parameters["contacts"].arrayObject {
                sendMessageParams["content"] = JSON(contacts)
            }
            
            if let typeCode = parameters["typeCode"].string {
                sendMessageParams["typeCode"] = JSON(typeCode)
            } else {
                sendMessageParams["typeCode"] = JSON(generalTypeCode)
            }
            
        }
        
        sendMessageWithCallback(params:         sendMessageParams,
                                callback:       AddParticipantsCallback(parameters: sendMessageParams),
                                callbacks:      nil,
                                sentCallback:   nil,
                                deliverCallback: nil,
                                seenCallback:   nil) { (addParticipantsUniqueId) in
            uniqueId(addParticipantsUniqueId)
        }
        addParticipantsCallbackToUser = completion
    }
    */
    
    
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
                                            content:            "\(removeParticipantsInput.content)",
                                            metaData:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          removeParticipantsInput.threadId,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           removeParticipantsInput.typeCode ?? generalTypeCode,
                                            uniqueId:           removeParticipantsInput.uniqueId,
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
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'RemoveParticipantsRequestModel' to get the parameters, it'll use JSON
    /*
    public func removeParticipants(params: JSON?, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        log.verbose("Try to request to remove participants with this parameters: \n \(params ?? "params is empty")", context: "Chat")
        
        /*
         * + RemoveParticipantsRequest    {object}
         *    - subjectId                 {long}
         *    + content                   {list} List of PARTICIPANT IDs from Thread's Participants object
         *       -id                      {long}
         *    - uniqueId                  {string}
         */
        
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.REMOVE_PARTICIPANT.rawValue]
        
        if let parameters = params {
            
            if let threadId = parameters["threadId"].int {
                if (threadId > 0) {
                    sendMessageParams["subjectId"] = JSON(threadId)
                }
            }
            
            if (parameters["participants"] != JSON.null) {
                sendMessageParams["content"] = JSON(parameters["participants"])
            }
            
            if let typeCode = parameters["typeCode"].string {
                sendMessageParams["typeCode"] = JSON(typeCode)
            } else {
                sendMessageParams["typeCode"] = JSON(generalTypeCode)
            }
            
        }
        
        sendMessageWithCallback(params:         sendMessageParams,
                                callback:       RemoveParticipantsCallback(parameters: sendMessageParams),
                                callbacks:      nil,
                                sentCallback:   nil,
                                deliverCallback: nil,
                                seenCallback:   nil) { (removeParticipantsUniqueId) in
            uniqueId(removeParticipantsUniqueId)
        }
        removeParticipantsCallbackToUser = completion
    }
    */
    
    
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
            var json: JSON = [:]
            json["userId"] = JSON(item.userId)
            json["roles"] = JSON(item.roles)
            json["roleOperation"] = JSON(item.roleOperation)
            json["checkThreadMembership"] = JSON(true)
            content.append(json)
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
    
    
}


