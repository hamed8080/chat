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
    /// - parameter uniqueId:       (response) it will returns the request 'UniqueId' that will send to server. (String)
    /// - parameter completion:     (response) it will returns the response that comes from server to this request. (Any as! UserInfoModel)
    /// - parameter cacheResponse:  (response) there is another response that comes from CacheDB to the user, if user has set 'enableCache' vaiable to be true. (UserInfoModel)
    public func getUserInfo(uniqueId:       @escaping ((String) -> ()),
                            completion:     @escaping callbackTypeAlias,
                            cacheResponse:  @escaping ((UserInfoModel) -> ())) {
        
        log.verbose("Try to request to get user info", context: "Chat")
        let theUniqueId = generateUUID()
        uniqueId(theUniqueId)
        
        userInfoCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.USER_INFO.rawValue,
                                            content:            nil,
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
                                callbacks:          [(UserInfoCallback(), theUniqueId)],
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil)
        
        // if cache is enabled by user, first return cache result to the user
        if enableCache {
            if let cacheUserInfoResult = Chat.cacheDB.retrieveUserInfo() {
                cacheResponse(cacheUserInfoResult)
            }
        }
        
    }
    
    
    public func serProfile(inputModel setProfileInput:  SetProfileRequestModel,
                           uniqueId:                    @escaping ((String) -> ()),
                           completion:                  @escaping callbackTypeAlias) {
        
        log.verbose("Try to request to set Profile", context: "Chat")
        
        uniqueId(setProfileInput.uniqueId)
        setProfileCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.SET_PROFILE.rawValue,
                                            content:            setProfileInput.convertContentToJSON().toString(),
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
                                callbacks:          [(SetProfileCallback(), setProfileInput.uniqueId)],
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil)
        
    }
    
    
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
    public func getChatState() -> JSON {
        return chatFullStateObject
    }
    
    // if your socket connection is disconnected you can reconnect it by calling this function
    public func reconnect() {
        asyncClient?.asyncReconnectSocket()
    }
    
    // this function will get a String and it will put it on 'token' variable, to use on your requests!
    public func setToken(newToken: String) {
        token = newToken
    }
    
    // log out from async
    public func logOut() {
        deleteCache()
        asyncClient?.asyncLogOut()
    }
    
}
