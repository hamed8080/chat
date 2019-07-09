//
//  UserInfoCallback.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 3/18/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON
import SwiftyBeaver
import FanapPodAsyncSDK

extension Chat {
    
    func chatDelegateUserInfo(userInfo: JSON) {
        
        let hasError = userInfo["hasError"].boolValue
        let errorMessage = userInfo["errorMessage"].stringValue
        let errorCode = userInfo["errorCode"].intValue
        
        if (!hasError) {
            let resultData = userInfo["result"]
            
            // save data comes from server to the Cache
            let user = User(messageContent: resultData)
            Chat.cacheDB.saveUserInfo(withUserObject: user)
            
            let userInfoModel = UserInfoModel(messageContent: resultData, hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
            
//            delegate?.userEvents(type: UserEventTypes.userInfo, result: userInfoModel)
        }
    }
    
    public class UserInfoCallback: CallbackProtocol {
        func onResultCallback(uID: String, response: JSON, success: @escaping callbackTypeAlias, failure: @escaping callbackTypeAlias) {
            log.verbose("UserInfoCallback", context: "Chat")
            
            let hasError = response["hasError"].boolValue
            let errorMessage = response["errorMessage"].stringValue
            let errorCode = response["errorCode"].intValue
            
            if (!hasError) {
                let resultData = response["result"]
                
                //                // save data comes from server to the Cache
                //                let user = User(messageContent: resultData)
                //                Chat.cacheDB.createUserInfoObject(user: user)
                
                let userInfoModel = UserInfoModel(messageContent: resultData, hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
                
                success(userInfoModel)
            } else {
                failure(["result": false])
            }
            
        }
    }
    
}
