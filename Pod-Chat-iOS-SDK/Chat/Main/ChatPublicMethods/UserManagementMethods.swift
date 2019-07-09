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
    
    
    /*
     * GetUserInfo:
     * it returns UserInfo.
     *
     * By calling this function, a request of type 23 (USER_INFO) will send throut Chat-SDK,
     * then the response will come back as callbacks to client whose calls this function.
     *
     *  + Inputs:
     *      - this method doesn't need any input
     *  + Outputs:
     *      It has 3 callbacks as response:
     *      1- uniqueId:        it will returns the request 'UniqueId' that will send to server.        (String)
     *      2- completion:      it will returns the response that comes from server to this request.    (UserInfoModel)
     *      3- cacheResponse:   there is another response that comes from CacheDB to the user, if user has set 'enableCache' vaiable to be true
     *
     */
    public func getUserInfo(uniqueId:       @escaping (String) -> (),
                            completion:     @escaping callbackTypeAlias,
                            cacheResponse:  @escaping (UserInfoModel) -> ()) {
        log.verbose("Try to request to get user info", context: "Chat")
        userInfoCallbackToUser = completion
        let sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.USER_INFO.rawValue,
                                       "typeCode": generalTypeCode]
        
        sendMessageWithCallback(params:         sendMessageParams,
                                callback:       UserInfoCallback(),
                                callbacks:      nil,
                                sentCallback:   nil,
                                deliverCallback: nil,
                                seenCallback:   nil) { (getUserInfoUniqueId) in
            uniqueId(getUserInfoUniqueId)
        }
        
        
        
        // if cache is enabled by user, first return cache result to the user
        if enableCache {
            if let cacheUserInfoResult = Chat.cacheDB.retrieveUserInfo() {
                cacheResponse(cacheUserInfoResult)
            }
        }
        
    }
    
    
    public func deleteUserInfoFromCache() {
        Chat.cacheDB.deleteUserInfo()
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
        asyncClient?.asyncLogOut()
    }
    
}
