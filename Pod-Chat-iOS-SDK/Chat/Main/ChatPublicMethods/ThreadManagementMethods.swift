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
    
    // MARK: - Get Thread
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
        log.verbose("Try to request to get threads with this parameters: \n \(getThreadsInput)", context: "Chat")
        
        //        var threadIdArr: [Int]?
        
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
            //            threadIdArr = threadIds
        }
        
        if let coreUserId = getThreadsInput.coreUserId {
            content["coreUserId"] = JSON(coreUserId)
        }
        
        if let metadataCriteria = getThreadsInput.metadataCriteria {
            content["metadataCriteria"] = JSON(metadataCriteria)
        }
        
        let sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.GET_THREADS.rawValue,
                                       "content": content,
                                       "typeCode": getThreadsInput.typeCode ?? generalTypeCode]
        
        sendMessageWithCallback(params: sendMessageParams, callback: GetThreadsCallbacks(parameters: sendMessageParams), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (getThreadUniqueId) in
            uniqueId(getThreadUniqueId)
        }
        threadsCallbackToUser = completion
        
        
        // if cache is enabled by user, it will return cache result to the user
        if enableCache {
            if let cacheThreads = Chat.cacheDB.retrieveThreads(ascending:   true,
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
        
        sendMessageWithCallback(params: sendMessageParams, callback: GetThreadsCallbacks(parameters: sendMessageParams), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (getThreadUniqueId) in
            uniqueId(getThreadUniqueId)
        }
        threadsCallbackToUser = completion
    }
    
    
    // MARK: - Create Thread
    /*
     CreateThread:
     create a thread with somebody
     
     By calling this function, a request of type 1 (CREATE_THREAD) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some optional prameters as an input, as JSON or Model (depends on the function that you would use) which are:
     - title:       give a title to the thread that you are going to create.    (String)
     - type:        type of the thread that you are creating.                   (String)
     - invitees:    this is also a JSON file that contains: "id" and "idType"   (Invitee)
     - uniqueId:
     
     + Outputs:
     It has 2 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- completion:  it will returns the response that comes from server to this request.    (CreateThreadModel)
     */
    public func createThread(createThreadInput: CreateThreadRequestModel,
                             uniqueId:          @escaping (String) -> (),
                             completion:        @escaping callbackTypeAlias) {
        log.verbose("Try to request to create thread participants with this parameters: \n \(createThreadInput)", context: "Chat")
        
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
            case ThreadTypes.NORMAL.rawValue:         theType = 0
            case ThreadTypes.OWNER_GROUP.rawValue:    theType = 1
            case ThreadTypes.PUBLIC_GROUP.rawValue:   theType = 2
            case ThreadTypes.CHANNEL_GROUP.rawValue:  theType = 4
            case ThreadTypes.CHANNEL.rawValue:        theType = 8
            default:
                //                print("not valid thread type on create thread")
                log.error("not valid thread type on create thread", context: "Chat")
            }
            content["type"] = JSON(theType)
        }
        
        let sendMessageCreateThreadParams: JSON = ["chatMessageVOType": chatMessageVOTypes.CREATE_THREAD.rawValue,
                                                   "content": content]
        sendMessageWithCallback(params: sendMessageCreateThreadParams, callback: CreateThreadCallback(parameters: sendMessageCreateThreadParams), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (createThreadUniqueId) in
            uniqueId(createThreadUniqueId)
        }
        
        createThreadCallbackToUser = completion
        
    }
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'CreateThreadRequestModel' to get the parameters, it'll use JSON
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
        sendMessageWithCallback(params: sendMessageCreateThreadParams, callback: CreateThreadCallback(parameters: sendMessageCreateThreadParams), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (createThreadUniqueId) in
            uniqueId(createThreadUniqueId)
        }
        
        createThreadCallbackToUser = completion
        
    }
    
    
    /*
     CreateThreadAndSendMessage:
     create a thread with somebody and simultaneously send a message on this thread.
     
     By calling this function, a request of type 1 (CREATE_THREAD) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some optional prameters as an input, as JSON or Model (depends on the function that you would use) which are:
     - threadTitle:       give a title to the thread that you are going to create.    (String)
     - threadType:        type of the thread that you are creating.                   (String)
     - threadInvitees:    this is also a JSON file that contains: "id" and "idType".  (Invitee)
     - uniqueId:
     - messageContent:       content of the message (the text Message).                      (String)
     - messageMetaDataId:    id property of the methadata of the message.                (Int)
     - messageMetaDataType:  type property of the methadata of the message.              (String)
     - messageMetaDataOwner: owner property of the methadata of the message.             (String)
     
     + Outputs:
     It has 4 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- completion:  it will returns the response that comes from server to this request.    (CreateThreadModel)
     3- onSent:
     4- onDelivere:
     5- onSeen:
     */
    public func createThreadWithMessage(creatThreadWithMessageInput: CreateThreadWithMessageRequestModel,
                                        uniqueId:                    @escaping (String) -> (),
                                        completion:                  @escaping callbackTypeAlias,
                                        onSent:                      @escaping callbackTypeAlias,
                                        onDelivere:                  @escaping callbackTypeAlias,
                                        onSeen:                      @escaping callbackTypeAlias) {
        log.verbose("Try to request to create thread and Send Message participants with this parameters: \n \(creatThreadWithMessageInput)", context: "Chat")
        
        let myUniqueId = creatThreadWithMessageInput.uniqueId ?? generateUUID()
        
        var messageContentParams: JSON = [:]
        messageContentParams["text"]     = JSON(creatThreadWithMessageInput.messageText)
        
        if let type = creatThreadWithMessageInput.messageType {
            messageContentParams["type"]    = JSON(type)
        }
        if let metaData = creatThreadWithMessageInput.messageMetaData {
            messageContentParams["metaData"]    = JSON(metaData)
        }
        if let systemMetadata = creatThreadWithMessageInput.messageSystemMetaData {
            messageContentParams["systemMetadata"]    = JSON(systemMetadata)
        }
        if let repliedTo = creatThreadWithMessageInput.messageRepliedTo {
            messageContentParams["repliedTo"]    = JSON(repliedTo)
        }
        if let forwardedMessageIds = creatThreadWithMessageInput.messageForwardedMessageIds {
            messageContentParams["forwardedMessageIds"]    = JSON(forwardedMessageIds)
        }
        if let forwardedUniqueIds = creatThreadWithMessageInput.messageForwardedUniqueIds {
            messageContentParams["forwardedUniqueIds"]    = JSON(forwardedUniqueIds)
        }
        messageContentParams["uniqueId"]    = JSON(myUniqueId)
        
        
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
        case ThreadTypes.NORMAL.rawValue:         theType = 0
        case ThreadTypes.OWNER_GROUP.rawValue:    theType = 1
        case ThreadTypes.PUBLIC_GROUP.rawValue:   theType = 2
        case ThreadTypes.CHANNEL_GROUP.rawValue:  theType = 4
        case ThreadTypes.CHANNEL.rawValue:        theType = 8
        default:
            //                print("not valid thread type on create thread")
            log.error("not valid thread type on create thread", context: "Chat")
        }
        myContent["type"] = JSON(theType)
        
        
        //        let myUniqueId = generateUUID()
        //
        //        var message: JSON = ["text": creatThreadWithMessageInput.messageContentText]
        //
        //        if let mui = creatThreadWithMessageInput.messageUniqueId {
        //            message["uniqueId"] = JSON("\(mui)")
        //        }
        //        if let mt = creatThreadWithMessageInput.messageType {
        //            message["type"] = JSON(mt)
        //        }
        //        if let mr = creatThreadWithMessageInput.messageRepliedTo {
        //            message["repliedTo"] = JSON(mr)
        //        }
        //        if let mmt = creatThreadWithMessageInput.messageMetaData {
        //            message["metadata"] = JSON("\(mmt)")
        //        }
        //        if let msmt = creatThreadWithMessageInput.messageSystemMetadata {
        //            message["systemMetadata"] = JSON("\(msmt)")
        //        }
        //        if let mfi = creatThreadWithMessageInput.messageForwardMessageIds {
        //            message["forwardedMessageIds"] = JSON(mfi)
        //            var uIds: [String] = []
        //            for _ in mfi {
        //                uIds.append(generateUUID())
        //            }
        //            message["forwardedUniqueIds"] = JSON(uIds)
        //        }
        //
        //
        //        var content: JSON = ["message": message]
        //        content["uniqueId"] = JSON(myUniqueId)
        //        content["title"] = JSON(creatThreadWithMessageInput.threadTitle)
        //        content["invitees"] = JSON(creatThreadWithMessageInput.threadInvitees)
        //
        //        if let image = creatThreadWithMessageInput.threadImage {
        //            content["image"] = JSON(image)
        //        }
        //        if let metaData = creatThreadWithMessageInput.threadMetadata {
        //            content["metadata"] = JSON(metaData)
        //        }
        //        if let description = creatThreadWithMessageInput.threadDescription {
        //            content["description"] = JSON(description)
        //        }
        //
        //        if let type = creatThreadWithMessageInput.threadType {
        //            var theType: Int = 0
        //            switch type {
        //            case ThreadTypes.NORMAL.rawValue:         theType = 0
        //            case ThreadTypes.OWNER_GROUP.rawValue:    theType = 1
        //            case ThreadTypes.PUBLIC_GROUP.rawValue:   theType = 2
        //            case ThreadTypes.CHANNEL_GROUP.rawValue:  theType = 4
        //            case ThreadTypes.CHANNEL.rawValue:        theType = 8
        //            default: log.error("not valid thread type on create thread", context: "Chat")
        //            }
        //            content["type"] = JSON(theType)
        //        }
        
        let sendMessageCreateThreadParams: JSON = ["chatMessageVOType": chatMessageVOTypes.CREATE_THREAD.rawValue,
                                                   "content": myContent,
                                                   "uniqueId": myUniqueId]
        
        //        sendMessageWithCallback(params: sendMessageCreateThreadParams,
        //                                callback: CreateThreadCallback(parameters: sendMessageCreateThreadParams),
        //                                sentCallback: SendMessageCallbacks(parameters: content),
        //                                deliverCallback: SendMessageCallbacks(parameters: content),
        //                                seenCallback: SendMessageCallbacks(parameters: content)) { (theUniqueId) in
        //                                    uniqueId(theUniqueId)
        //        }
        
        
        messageContentParams["isCreateThreadAndSendMessage"] = JSON(true)
        sendMessageWithCallback(params: sendMessageCreateThreadParams, callback: CreateThreadCallback(parameters: sendMessageCreateThreadParams),
                                sentCallback: SendMessageCallbacks(parameters: messageContentParams),
                                deliverCallback: SendMessageCallbacks(parameters: messageContentParams),
                                seenCallback: SendMessageCallbacks(parameters: messageContentParams)) { (theUniqueId) in
                                    uniqueId(theUniqueId)
        }
        
        createThreadCallbackToUser = completion
        sendCallbackToUserOnSent = onSent
        sendCallbackToUserOnDeliver = onDelivere
        sendCallbackToUserOnSeen = onSeen
        
    }
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'CreateThreadWithMessageRequestModel' to get the parameters, it'll use JSON
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
        
        sendMessageWithCallback(params: sendMessageCreateThreadParams, callback: CreateThreadCallback(parameters: sendMessageCreateThreadParams), sentCallback: SendMessageCallbacks(parameters: sendMessageCreateThreadParams), deliverCallback: SendMessageCallbacks(parameters: sendMessageCreateThreadParams), seenCallback: SendMessageCallbacks(parameters: sendMessageCreateThreadParams)) { (theUniqueId) in
            uniqueId(theUniqueId)
        }
        
        createThreadCallbackToUser = completion
        sendCallbackToUserOnSent = onSent
        sendCallbackToUserOnDeliver = onDelivere
        sendCallbackToUserOnSeen = onSeen
    }
    
    // NOTE: This method will be deprecate
    // implement creating a thread and sending a message with it, handeled by this SDK (not server!)
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
     2- completion:  it will returns the response that comes from server to this request.    (CreateThreadModel)
     */
    public func leaveThread(leaveThreadInput:   LeaveThreadRequestModel,
                            uniqueId:           @escaping (String) -> (),
                            completion:         @escaping callbackTypeAlias) {
        log.verbose("Try to request to leave thread with this parameters: \n \(leaveThreadInput)", context: "Chat")
        
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.LEAVE_THREAD.rawValue,
                                       "typeCode": leaveThreadInput.typeCode ?? generalTypeCode,
                                       "subjectId": leaveThreadInput.threadId]
        
        if let uniqueId = leaveThreadInput.uniqueId {
            sendMessageParams["uniqueId"] = JSON(uniqueId)
        }
        
        sendMessageWithCallback(params: sendMessageParams, callback: LeaveThreadCallbacks(), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (leaveThreadUniqueId) in
            uniqueId(leaveThreadUniqueId)
        }
        leaveThreadCallbackToUser = completion
        
    }
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'LeaveThreadRequestModel' to get the parameters, it'll use JSON
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
        
        sendMessageWithCallback(params: sendMessageParams, callback: LeaveThreadCallbacks(), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (leaveThreadUniqueId) in
            uniqueId(leaveThreadUniqueId)
        }
        leaveThreadCallbackToUser = completion
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
        log.verbose("Try to request to update thread info with this parameters: \n \(updateThreadInfoInput)", context: "Chat")
        
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.UPDATE_THREAD_INFO.rawValue,
                                       "typeCode": updateThreadInfoInput.typeCode ?? generalTypeCode]
        
        if let threadId = updateThreadInfoInput.subjectId {
            sendMessageParams["threadId"] = JSON(threadId)
            sendMessageParams["subjectId"] = JSON(threadId)
            
        } else {
            delegate?.chatError(errorCode: 999, errorMessage: "Thread ID is required for Updating thread info!", errorResult: nil)
        }
        
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
        
        sendMessageParams["content"] = JSON("\(content)")
        
        sendMessageWithCallback(params: sendMessageParams, callback: UpdateThreadInfoCallback(), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (updateThreadInfoUniqueId) in
            uniqueId(updateThreadInfoUniqueId)
        }
        updateThreadInfoCallbackToUser = completion
    }
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'UpdateThreadInfoRequestModel' to get the parameters, it'll use JSON
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
        
        sendMessageWithCallback(params: sendMessageParams, callback: UpdateThreadInfoCallback(), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (updateThreadInfoUniqueId) in
            uniqueId(updateThreadInfoUniqueId)
        }
        updateThreadInfoCallbackToUser = completion
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
        log.verbose("Try to request to spam thread with this parameters: \n \(spamPvThreadInput)", context: "Chat")
        
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.SPAM_PV_THREAD.rawValue,
                                       "typeCode": spamPvThreadInput.typeCode ?? generalTypeCode]
        
        if let subjectId = spamPvThreadInput.threadId {
            sendMessageParams["subjectId"] = JSON(subjectId)
        }
        
        sendMessageWithCallback(params: sendMessageParams, callback: SpamPvThread(), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (spamUniqueId) in
            uniqueId(spamUniqueId)
        }
        spamPvThreadCallbackToUser = completion
    }
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'SpamPvThreadRequestModel' to get the parameters, it'll use JSON
    public func spamPvThread(params: JSON, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        log.verbose("Try to request to spam thread with this parameters: \n \(params)", context: "Chat")
        
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.SPAM_PV_THREAD.rawValue,
                                       "typeCode": params["typeCode"].string ?? generalTypeCode]
        
        if let subjectId = params["threadId"].int {
            sendMessageParams["subjectId"] = JSON(subjectId)
        }
        
        sendMessageWithCallback(params: sendMessageParams, callback: SpamPvThread(), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (spamUniqueId) in
            uniqueId(spamUniqueId)
        }
        spamPvThreadCallbackToUser = completion
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
        log.verbose("Try to request to mute threads with this parameters: \n \(muteThreadInput)", context: "Chat")
        
        let sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.MUTE_THREAD.rawValue,
                                       "typeCode": muteThreadInput.typeCode ?? generalTypeCode,
                                       "subjectId": muteThreadInput.subjectId]
        
        sendMessageWithCallback(params: sendMessageParams, callback: MuteThreadCallbacks(), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (muteThreadUniqueId) in
            uniqueId(muteThreadUniqueId)
        }
        muteThreadCallbackToUser = completion
        
    }
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'MuteAndUnmuteThreadRequestModel' to get the parameters, it'll use JSON
    public func muteThread(params: JSON, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        log.verbose("Try to request to mute threads with this parameters: \n \(params)", context: "Chat")
        
        let sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.MUTE_THREAD.rawValue,
                                       "typeCode": params["typeCode"].string ?? generalTypeCode,
                                       "subjectId": params["subjectId"].intValue]
        
        sendMessageWithCallback(params: sendMessageParams, callback: MuteThreadCallbacks(), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (muteThreadUniqueId) in
            uniqueId(muteThreadUniqueId)
        }
        muteThreadCallbackToUser = completion
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
        log.verbose("Try to request to unmute threads with this parameters: \n \(unmuteThreadInput)", context: "Chat")
        
        let sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.UNMUTE_THREAD.rawValue,
                                       "typeCode": unmuteThreadInput.typeCode ?? generalTypeCode,
                                       "subjectId": unmuteThreadInput.subjectId]
        
        sendMessageWithCallback(params: sendMessageParams, callback: UnmuteThreadCallbacks(), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (muteThreadUniqueId) in
            uniqueId(muteThreadUniqueId)
        }
        unmuteThreadCallbackToUser = completion
    }
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'MuteAndUnmuteThreadRequestModel' to get the parameters, it'll use JSON
    public func unmuteThread(params: JSON, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        log.verbose("Try to request to unmute threads with this parameters: \n \(params)", context: "Chat")
        
        let sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.UNMUTE_THREAD.rawValue,
                                       "typeCode": params["typeCode"].string ?? generalTypeCode,
                                       "subjectId": params["subjectId"].intValue]
        
        sendMessageWithCallback(params: sendMessageParams, callback: UnmuteThreadCallbacks(), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (muteThreadUniqueId) in
            uniqueId(muteThreadUniqueId)
        }
        unmuteThreadCallbackToUser = completion
    }
    
    
    // MARK: - Get/Add/Remove ThreadParticipants
    /*
     GetThreadParticipants:
     get all participants in a specific thread.
     
     By calling this function, a request of type 27 (THREAD_PARTICIPANTS) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some optional prameters as an input, as JSON or Model (depends on the function that you would use) which are:
     - threadId:    id of the thread that you want to mute it.    (Int)
     - count:
     - offset:
     - firstMessageId:
     - lastMessageId:
     - name:
     - typeCode:
     
     + Outputs:
     It has 2 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- completion:  it will returns the response that comes from server to this request.    (GetThreadParticipantsModel)
     3- cacheResponse:  there is another response that comes from CacheDB to the user, if user has set 'enableCache' vaiable to be true
     */
    public func getThreadParticipants(getThreadParticipantsInput:   GetThreadParticipantsRequestModel,
                                      uniqueId:                     @escaping (String) -> (),
                                      completion:                   @escaping callbackTypeAlias,
                                      cacheResponse:                @escaping (GetThreadParticipantsModel) -> ()) {
        log.verbose("Try to request to get thread participants with this parameters: \n \(getThreadParticipantsInput)", context: "Chat")
        
        var content: JSON = [:]
        content["threadId"] = JSON(getThreadParticipantsInput.threadId)
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
        
        let sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.THREAD_PARTICIPANTS.rawValue,
                                       "typeCode": getThreadParticipantsInput.typeCode ?? generalTypeCode,
                                       "content": content,
                                       "subjectId": getThreadParticipantsInput.threadId]
        sendMessageWithCallback(params: sendMessageParams, callback: GetThreadParticipantsCallbacks(parameters: sendMessageParams), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (getParticipantsUniqueId) in
            uniqueId(getParticipantsUniqueId)
        }
        threadParticipantsCallbackToUser = completion
        
        
        // if cache is enabled by user, it will return cache result to the user
        if enableCache {
            if let cacheThreadParticipants = Chat.cacheDB.retrieveThreadParticipants(ascending: true,
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
        sendMessageWithCallback(params: sendMessageParams, callback: GetThreadParticipantsCallbacks(parameters: sendMessageParams), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (getParticipantsUniqueId) in
            uniqueId(getParticipantsUniqueId)
        }
        threadParticipantsCallbackToUser = completion
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
        log.verbose("Try to request to add participants with this parameters: \n \(addParticipantsInput)", context: "Chat")
        
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.ADD_PARTICIPANT.rawValue]
        sendMessageParams["subjectId"] = JSON(addParticipantsInput.threadId)
        sendMessageParams["content"] = JSON(addParticipantsInput.contacts)
        sendMessageParams["typeCode"] = JSON(addParticipantsInput.typeCode ?? generalTypeCode)
        
        if let uniqueId = addParticipantsInput.uniqueId {
            sendMessageParams["uniqueId"] = JSON(uniqueId)
        }
        
        sendMessageWithCallback(params: sendMessageParams, callback: AddParticipantsCallback(parameters: sendMessageParams), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (addParticipantsUniqueId) in
            uniqueId(addParticipantsUniqueId)
        }
        addParticipantsCallbackToUser = completion
        
    }
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'AddParticipantsRequestModel' to get the parameters, it'll use JSON
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
        
        sendMessageWithCallback(params: sendMessageParams, callback: AddParticipantsCallback(parameters: sendMessageParams), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (addParticipantsUniqueId) in
            uniqueId(addParticipantsUniqueId)
        }
        addParticipantsCallbackToUser = completion
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
        log.verbose("Try to request to remove participants with this parameters: \n \(removeParticipantsInput)", context: "Chat")
        
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.REMOVE_PARTICIPANT.rawValue]
        sendMessageParams["subjectId"] = JSON(removeParticipantsInput.threadId)
        sendMessageParams["content"] = JSON(removeParticipantsInput.content)
        sendMessageParams["typeCode"] = JSON(removeParticipantsInput.typeCode ?? generalTypeCode)
        
        if let uniqueId = removeParticipantsInput.uniqueId {
            sendMessageParams["uniqueId"] = JSON(uniqueId)
        }
        
        sendMessageWithCallback(params: sendMessageParams, callback: RemoveParticipantsCallback(parameters: sendMessageParams), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (removeParticipantsUniqueId) in
            uniqueId(removeParticipantsUniqueId)
        }
        removeParticipantsCallbackToUser = completion
        
    }
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'RemoveParticipantsRequestModel' to get the parameters, it'll use JSON
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
        
        sendMessageWithCallback(params: sendMessageParams, callback: RemoveParticipantsCallback(parameters: sendMessageParams), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (removeParticipantsUniqueId) in
            uniqueId(removeParticipantsUniqueId)
        }
        removeParticipantsCallbackToUser = completion
    }
    
    
    
    // MARK: - Get/Set/Remove AdminRole
    
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
                                callback: GetAdminListCallback(parameters: sendMessageGetAdminListParams),
                                sentCallback: nil,
                                deliverCallback: nil,
                                seenCallback: nil) { (getAminListUniqueId) in
                                    uniqueId(getAminListUniqueId)
        }
        
        getAdminListCallbackToUser = completion
    }
    
    
    public func setRole(setRoleInput:   [SetRoleRequestModel],
                        uniqueId:       @escaping (String) -> (),
                        completion:     @escaping callbackTypeAlias,
                        cacheResponse:  @escaping callbackTypeAlias) {
        
        var content: [JSON] = []
//        var content: JSON = [:]
        
        for item in setRoleInput {
            var json: JSON = [:]
            json["userId"] = JSON(item.userId)
            json["roles"] = JSON(item.roles)
            json["roleOperation"] = JSON(item.roleOperation)
            json["checkThreadMembership"] = JSON(true)
//            content = json
            content.append(json)
        }
        
        //        for item in setRoleInput.roles {
        //            var json: JSON = [:]
        //            json["userId"] = JSON(setRoleInput.userId)
        ////            json["checkThreadMembership"] = JSON(true)
        //            json["roles"] = [JSON(item)]
        //            json["roleOperation"] = JSON(setRoleInput.roleOperation)
        //            content.append(json)
        //        }
        
        //        content["userId"] = JSON(setAdminInput.threadId)
        //        content["checkThreadMembership"] = JSON(true)
        //        content["roleTypes"] = JSON(setAdminInput.roles)
        //        content["roleOperation"] = JSON(setAdminInput.roles)
        
        //        if let requestUniqueId = setAdminInput.uniqueId {
        //            content["uniqueId"] = JSON(requestUniqueId)
        //        }
        
        let sendMessageSetRoleToUserParams: JSON = ["chatMessageVOType": chatMessageVOTypes.SET_RULE_TO_USER.rawValue,
                                                    "content": content,
                                                    "subjectId": setRoleInput.first!.threadId]
        
        sendMessageWithCallback(params: sendMessageSetRoleToUserParams,
                                callback: SetRoleToUserCallback(parameters: sendMessageSetRoleToUserParams),
                                sentCallback: nil,
                                deliverCallback: nil,
                                seenCallback: nil) { (getAminListUniqueId) in
                                    uniqueId(getAminListUniqueId)
        }
        
        setRoleToUserCallbackToUser = completion
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
        log.verbose("Try to request to get history with this parameters: \n \(getHistoryInput)", context: "Chat")
        
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
        
        
        //        var asscenging = true
        if let order = getHistoryInput.order {
            content["order"] = JSON(order)
            //            if (order == "DESC") {
            //                asscenging = false
            //            }
        }
        
        if let query = getHistoryInput.query {
            content["query"] = JSON(query)
        }
        
        if let metadataCriteria = getHistoryInput.metadataCriteria {
            content["metadataCriteria"] = JSON(metadataCriteria)
        }
        
        let sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.GET_HISTORY.rawValue,
                                       "content": content,
                                       "typeCode": getHistoryInput.typeCode ?? generalTypeCode,
                                       "subjectId": getHistoryInput.threadId]
        
        sendMessageWithCallback(params: sendMessageParams, callback: GetHistoryCallbacks(parameters: sendMessageParams), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (getHistoryUniqueId) in
            uniqueId(getHistoryUniqueId)
        }
        historyCallbackToUser = completion
        
        
        
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
        
        sendMessageWithCallback(params: sendMessageParams, callback: GetHistoryCallbacks(parameters: sendMessageParams), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (getHistoryUniqueId) in
            uniqueId(getHistoryUniqueId)
        }
        historyCallbackToUser = completion
    }
    
    
    /*
     ClearHistory
     
     */
    public func clearHistory(clearHistoryInput: ClearHistoryRequestModel,
                             uniqueId:          @escaping (String) -> (),
                             completion:        @escaping callbackTypeAlias,
                             cacheResponse:     @escaping callbackTypeAlias) {
        log.verbose("Try to request to create clear history with this parameters: \n \(clearHistoryInput)", context: "Chat")
        
        var content: JSON = [:]
        
        if let requestUniqueId = clearHistoryInput.uniqueId {
            content["uniqueId"] = JSON(requestUniqueId)
        }
        
        let sendMessageClearHistoryParams: JSON = ["chatMessageVOType": chatMessageVOTypes.CLEAR_HISTORY.rawValue,
                                                   "content": content,
                                                   "subjectId": clearHistoryInput.threadId]
        
        sendMessageWithCallback(params: sendMessageClearHistoryParams,
                                callback: ClearHistoryCallback(parameters: sendMessageClearHistoryParams),
                                sentCallback:   nil,
                                deliverCallback: nil,
                                seenCallback:   nil) { (clearHistoryUniqueId) in
                                    uniqueId(clearHistoryUniqueId)
        }
        
        clearHistoryCallbackToUser = completion
    }
    
    
}


