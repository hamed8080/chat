//
//  GetUserInfoCallback.swift
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
    
    // TODO: complete the comments
    // TODO: take a look at the failure state (and check if all things is right)
    /// UserInfo Response comes from server
    ///
    /// - Outputs:
    ///    - it doesn't have direct output,
    ///    - but on the situation where the response is valid,
    ///    - it will call the "onResultCallback" callback to getUserInfo function (by using "userInfoCallbackToUser")
    @available(*,deprecated , message:"Removed in 0.10.5.0 version")
    func responseOfUserInfo(withMessage message: ChatMessage) {
        log.verbose("Message of type 'USER_INFO' recieved", context: "Chat")
        
        let returnData = CreateReturnData(hasError:         false,
                                          errorMessage:     "",
                                          errorCode:        0,
                                          result:           message.content?.convertToJSON() ?? [:],
                                          resultAsArray:    nil,
                                          resultAsString:   nil,
                                          contentCount:     nil,
                                          subjectId:        message.subjectId)
        
        let systemEventModel = SystemEventModel(type:       SystemEventTypes.SERVER_TIME,
                                                time:       message.time,
                                                threadId:   nil,
                                                user:       nil)
        Chat.sharedInstance.delegate?.systemEvents(model: systemEventModel)
        
        if enableCache {
            let user = User(messageContent: message.content?.convertToJSON() ?? [:])
            Chat.cacheDB.saveUserInfo(withUserObject: user)
        }
        
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
                                             errorMessage:  ChatErrors.err6001.stringValue(),
                                             errorResult:   nil)
                } else {
                    self.handleAsyncReady()
                }
            }
            Chat.map.removeValue(forKey: message.uniqueId)
        }
        
    }
    
    @available(*,deprecated , message:"Removed in 0.10.5.0 version")
    public class GetUserInfoCallback: CallbackProtocol {
        
        func onResultCallback(uID:      String,
                              response: CreateReturnData,
                              success:  @escaping callbackTypeAlias,
                              failure:  @escaping callbackTypeAlias) {
            log.verbose("UserInfoCallback", context: "Chat")
            
            if let content = response.result {
                let userInfoModel = GetUserInfoResponse(messageContent: content,
                                                        hasError:       response.hasError,
                                                        errorMessage:   response.errorMessage,
                                                        errorCode:      response.errorCode)
                success(userInfoModel)
            } else {
                failure(["result": false])
            }
        }
        
    }
    
}
