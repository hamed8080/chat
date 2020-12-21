//
//  UserManagementMethods.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 3/21/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import FanapPodAsyncSDK
import SwiftyJSON

// MARK: - Public Methods
// MARK: - User Management

extension Chat {
    
    /*
     This function will retuen peerId of the current user if it exists, else it would return 0
     */
    public func getPeerId() -> Int {
        if let id = peerId {
            return id
        } else {
            return 0
        }
    }
    
    /*
     This function will return the current user info if it exists, otherwise it would return nil!
     */
    public func getCurrentUser() -> User? {
        if let myUserInfo = userInfo {
            return myUserInfo
        } else {
            return nil
        }
    }
    
    
    /// GetUserInfo:
    /// this function will return UserInfo
    ///
    /// By calling this function, a request of type 23 (USER_INFO) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - this method doesn't need any input
    ///
    /// Outputs:
    /// - It has 3 callbacks as responses
    ///
    /// - parameter getCacheResponse:   (input) specify if you want to get cache response for this request (Bool?)
    /// - parameter uniqueId:           (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion:         (response) it will returns the response that comes from server to this request. (Any as! UserInfoModel)
    /// - parameter cacheResponse:      (response) there is another response that comes from CacheDB to the user, if user has set 'enableCache' vaiable to be true. (UserInfoModel)
    public func getUserInfo(getCacheResponse:   Bool?,
                            uniqueId:       @escaping ((String) -> ()),
                            completion:     @escaping callbackTypeAlias,
                            cacheResponse:  @escaping ((UserInfoModel) -> ())) {
        
        log.verbose("Try to request to get user info", context: "Chat")
        let theUniqueId = generateUUID()
        uniqueId(theUniqueId)
        
        userInfoCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  ChatMessageVOTypes.USER_INFO.intValue(),
                                            content:            nil,
                                            messageType:        nil,
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          nil,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           generalTypeCode,
                                            uniqueId:           theUniqueId,
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: nil)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  nil)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callbacks:          [(GetUserInfoCallback(), theUniqueId)],
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil)
        
        // if cache is enabled by user, first return cache result to the user
        if (getCacheResponse ?? enableCache) {
            if let cacheUserInfoResult = Chat.cacheDB.retrieveUserInfo() {
                cacheResponse(cacheUserInfoResult)
            }
        }
        
    }
    
    /// SetProfile:
    /// this function will set Bio and Metadata to the user, and it will save on the UserInfo model
    ///
    /// By calling this function, a request of type 52 (SET_PROFILE) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "UpdateChatProfileRequest" to this function
    ///
    /// Outputs:
    /// - It has 2 callbacks as responses
    ///
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion: (response) it will returns the response that comes from server to this request. (Any as! ProfileModel)
    public func setProfile(inputModel setProfileInput:  UpdateChatProfileRequest,
                           uniqueId:                    @escaping ((String) -> ()),
                           completion:                  @escaping callbackTypeAlias) {
        
        log.verbose("Try to request to set Profile", context: "Chat")
        
        uniqueId(setProfileInput.uniqueId)
        updateChatProfileCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  ChatMessageVOTypes.SET_PROFILE.intValue(),
                                            content:            setProfileInput.convertContentToJSON().toString(),
                                            messageType:        nil,
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          nil,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           setProfileInput.typeCode ?? generalTypeCode,
                                            uniqueId:           setProfileInput.uniqueId,
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: nil)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  nil)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callbacks:          [(UpdateChatProfileCallback(), setProfileInput.uniqueId)],
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil)
        
    }
    
    
    // MARK: - Block/Unblock/GetBlockList Contact
    
    /// BlockContact:
    /// block a contact by its contactId.
    ///
    /// By calling this function, a request of type 7 (BLOCK) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "BlockRequest" to this function
    ///
    /// Outputs:
    /// - It has 3 callbacks as responses.
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (BlockRequest)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion: (response) it will returns the response that comes from server to this request. (Any as! BlockedUserModel)
    public func blockContact(inputModel blockContactsInput:    BlockRequest,
                             uniqueId:              @escaping (String) -> (),
                             completion:            @escaping callbackTypeAlias) {
        
        log.verbose("Try to request to block user with this parameters: \n \(blockContactsInput)", context: "Chat")
        uniqueId(blockContactsInput.uniqueId)
        blockCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  ChatMessageVOTypes.BLOCK.intValue(),
                                            content:            "\(blockContactsInput.convertContentToJSON())",
                                            messageType:        nil,
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          nil,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           blockContactsInput.typeCode ?? generalTypeCode,
                                            uniqueId:           blockContactsInput.uniqueId,
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: true)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  nil)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callbacks:          [(BlockCallbacks(), blockContactsInput.uniqueId)],
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil)
    }
    
    
    /// GetBlockContactsList:
    /// it returns a list of the blocked contacts.
    ///
    /// By calling this function, a request of type 25 (GET_BLOCKED) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "GetBlockedListRequest" to this function
    ///
    /// Outputs:
    /// - It has 3 callbacks as responses.
    ///
    /// - parameter inputModel:         (input) you have to send your parameters insid this model. (GetBlockedListRequest)
    /// - parameter getCacheResponse:   (input) specify if you want to get cache response for this request (Bool?)
    /// - parameter uniqueId:           (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion:         (response) it will returns the response that comes from server to this request. (Any as! GetBlockedUserListModel)
    public func getBlockedContacts(inputModel getBlockedContactsInput:  GetBlockedListRequest,
                                   getCacheResponse:                    Bool?,
                                   uniqueId:                @escaping (String) -> (),
                                   completion:              @escaping callbackTypeAlias) {
        
        log.verbose("Try to request to get block users with this parameters: \n \(getBlockedContactsInput)", context: "Chat")
        uniqueId(getBlockedContactsInput.uniqueId)
        getBlockedListCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  ChatMessageVOTypes.GET_BLOCKED.intValue(),
                                            content:            "\(getBlockedContactsInput.convertContentToJSON())",
                                            messageType:        nil,
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          nil,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           getBlockedContactsInput.typeCode ?? generalTypeCode,
                                            uniqueId:           getBlockedContactsInput.uniqueId,
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: true)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  nil)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callbacks:          [(GetBlockedUsersCallbacks(parameters: chatMessage), getBlockedContactsInput.uniqueId)],
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil)
        
        if (getCacheResponse ?? enableCache) {
            // ToDo:
        }
        
    }
    
    /// SendStatusPing:
    ///
    ///
    /// By calling this function, a request of type 101 (STATUS_PING) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "StatusPingRequest" to this function
    ///
    /// Outputs:
    /// - It has 3 callbacks as responses.
    ///
    /// - parameter inputModel:         (input) you have to send your parameters insid this model. (StatusPingRequest)
//    /// - parameter uniqueId:           (response) it will returns the request 'UniqueId' that will send to server. (String)
//    /// - parameter completion:         (response) it will returns the response that comes from server to this request. (Any as! )
    public func sendStatusPing(inputModel statusPingInput: StatusPingRequest) {
//                               uniqueId:                @escaping (String) -> (),
//                               completion:              @escaping callbackTypeAlias) {
        log.verbose("Try to send Status Ping with this parameters: \n threadId = \(statusPingInput.threadId ?? 2) \n contactId = \(statusPingInput.contactId ?? 3)", context: "Chat")
//        uniqueId(statusPingInput.uniqueId)
//
//        statusPingCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  ChatMessageVOTypes.STATUS_PING.intValue(),
                                            content:            "\(statusPingInput.convertContentToJSON())",
                                            messageType:        nil,
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          nil,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           statusPingInput.typeCode ?? generalTypeCode,
                                            uniqueId:           statusPingInput.uniqueId,
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: true)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  nil)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callbacks:          nil,//[(StatusPingCallback(), statusPingInput.uniqueId)],
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil)
    }
    
    
    
    /// UnblockContact:
    /// unblock a contact from blocked list.
    ///
    /// By calling this function, a request of type 8 (UNBLOCK) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "UnblockRequest" to this function
    ///
    /// Outputs:
    /// - It has 3 callbacks as responses.
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (UnblockRequest)
    /// - parameter uniqueId:   (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion: (response) it will returns the response that comes from server to this request. (Any as! BlockedUserModel)
    public func unblockContact(inputModel unblockContactsInput:    UnblockRequest,
                               uniqueId:                @escaping (String) -> (),
                               completion:              @escaping callbackTypeAlias) {
        
        log.verbose("Try to request to unblock user with this parameters: \n \(unblockContactsInput)", context: "Chat")
        uniqueId(unblockContactsInput.uniqueId)
        
        unblockUserCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  ChatMessageVOTypes.UNBLOCK.intValue(),
                                            content:            "\(unblockContactsInput.convertContentToJSON())",
                                            messageType:        nil,
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          unblockContactsInput.blockId,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           unblockContactsInput.typeCode ?? generalTypeCode,
                                            uniqueId:           unblockContactsInput.uniqueId,
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: true)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  nil)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callbacks:          [(UnblockCallbacks(), unblockContactsInput.uniqueId)],
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil)
    }
    
    
    
    /// DeleteUserInfoFromCache:
    /// this function will delete the UserInfo data from cahce database
    ///
    /// Inputs:
    /// - this method does not any input to send
    ///
    /// Outputs:
    /// - this method does not any output
    public func deleteUserInfoFromCache() {
        Chat.cacheDB.deleteUserInfo(isCompleted: nil)
    }
    
    
    // this function will generate a UUID to use in your request if needed (specially for uniqueId)
    // and it will return the UUID as String
    public func generateUUID() -> String {
        let myUUID = NSUUID().uuidString
        return myUUID
    }
    
    
    // this function will return Chate State as JSON
    public func getChatState() -> ChatFullStateModel? {
        return chatFullStateObject
    }
    
    // if your socket connection is disconnected you can reconnect it by calling this function
    public func reconnect() {
        asyncClient?.asyncReconnectSocket()
    }
    
    /// SetToken:
    /// by using this method you can set token to use on your requests
    ///
    /// Inputs:
    /// - this method gets 'newToken' as 'String' value
    ///
    /// Outputs:
    /// - this method does not any output
    public func setToken(newToken: String) {
        token = newToken
    }
    
    // log out from async
    /// LogOut:
    /// by calling this metho, youe all cache data will delete and then you will logout from async
    ///
    /// Inputs:
    /// - this method does not any input
    ///
    /// Outputs:
    /// - this method does not any output
    public func logOut() {
        deleteCache()
        stopAllChatTimers()
        asyncClient?.disposeAsyncObject()
    }
    
    
    public func disconnectChat() {
        stopAllChatTimers()
        asyncClient?.disposeAsyncObject()
    }
    
}
