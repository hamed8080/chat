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
    
    /*
     * UserInfo Response comes from server
     *
     *  save data comes from server to the Cache if needed
     *  send Event to client if needed!
     *  call the "onResultCallback"
     *
     *  + Access:   - private
     *  + Inputs:
     *      - message:      ChatMessage
     *  + Outputs:
     *      - it doesn't have direct output,
     *          but on the situation where the response is valid,
     *          it will call the "onResultCallback" callback to getUserInfo function (by using "userInfoCallbackToUser")
     *
     */
    // TODO: complete the comments
    // TODO: take a look at the failure state (and check if all things is right)
    func responseOfUserInfo(withMessage message: ChatMessage) {
        /*
         *  -> check if we have saves the message uniqueId on the "map" property
         *      -> if yes: (means we send this request and waiting for the response of it)
         *          -> create the "CreateReturnData" variable
         *          -> check if Cache is enabled by the user
         *              -> if yes, save the income Data to the Cache
         *          -> call the "onResultCallback" which will send callback to getUserInfo function (by using "userInfoCallbackToUser")
         *
         */
        log.verbose("Message of type 'USER_INFO' recieved", context: "Chat")
        
        let returnData = CreateReturnData(hasError:         false,
                                          errorMessage:     "",
                                          errorCode:        0,
                                          result:           message.content?.convertToJSON() ?? [:],
                                          resultAsArray:    nil,
                                          resultAsString:   nil,
                                          contentCount:     nil,
                                          subjectId:        message.subjectId)
        
        let systemEventModel = SystemEventModel(type: SystemEventTypes.SERVER_TIME, time: message.time, threadId: nil, user: nil)
        Chat.sharedInstance.delegate?.systemEvents(model: systemEventModel)
        
        if enableCache {
            let user = User(messageContent: message.content?.convertToJSON() ?? [:])
            Chat.cacheDB.saveUserInfo(withUserObject: user)
        }
//            delegate?.userEvents(type: UserEventTypes.userInfo, result: userInfo)
        
        if Chat.map[message.uniqueId] != nil {    
            let callback: CallbackProtocol = Chat.map[message.uniqueId]!
            callback.onResultCallback(uID:      message.uniqueId,
                                      response: returnData,
                                      success:  { (myUserInfoModel) in
                self.getUserInfoRetryCount = 0
                // here has to send callback to getuserInfo function
                self.userInfoCallbackToUser?(myUserInfoModel)
            }) { (failureJSON) in
                if (self.getUserInfoRetryCount > self.getUserInfoRetry) {
                    self.delegate?.chatError(errorCode:     6101,
                                             errorMessage:  CHAT_ERRORS.err6001.rawValue,
                                             errorResult:   nil)
                } else {
                    self.handleAsyncReady()
                }
            }
            Chat.map.removeValue(forKey: message.uniqueId)
        }
        
    }
    
    public class UserInfoCallback: CallbackProtocol {
        
        func onResultCallback(uID:      String,
                              response: CreateReturnData,
                              success:  @escaping callbackTypeAlias,
                              failure:  @escaping callbackTypeAlias) {
            /*
             *  -> check if response hasError or not
             *      -> if not, create the "UserInfoModel"
             *          -> send the "UserInfoModel" as a callback
             *
             */
            log.verbose("UserInfoCallback", context: "Chat")
            if let content = response.result {
                let userInfoModel = UserInfoModel(messageContent:   content,
                                                  hasError:         response.hasError,
                                                  errorMessage:     response.errorMessage,
                                                  errorCode:        response.errorCode)
                success(userInfoModel)
            } else {
                failure(["result": false])
            }
        }
        
    }
    
}
