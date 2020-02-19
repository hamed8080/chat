//
//  SetProfileCallback.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 11/20/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import FanapPodAsyncSDK


extension Chat {
    
    func responseOfSetProfile(withMessage message: ChatMessage) {
        log.verbose("Message of type 'SET_PROFILE' recieved", context: "Chat")
        
        let returnData = CreateReturnData(hasError:         false,
                                          errorMessage:     "",
                                          errorCode:        0,
                                          result:           message.content?.convertToJSON() ?? [:],
                                          resultAsArray:    nil,
                                          resultAsString:   nil,
                                          contentCount:     nil,
                                          subjectId:        message.subjectId)
        
        if Chat.map[message.uniqueId] != nil {
            let callback: CallbackProtocol = Chat.map[message.uniqueId]!
            callback.onResultCallback(uID:      message.uniqueId,
                                      response: returnData,
                                      success:  { (setProfileResponse) in
                // here has to send callback to getuserInfo function
                self.setProfileCallbackToUser?(setProfileResponse)
            }) { _ in }
            Chat.map.removeValue(forKey: message.uniqueId)
        }
        
    }
    
    public class SetProfileCallback: CallbackProtocol {
        
        func onResultCallback(uID:      String,
                              response: CreateReturnData,
                              success:  @escaping callbackTypeAlias,
                              failure:  @escaping callbackTypeAlias) {
            log.verbose("SetProfileCallback", context: "Chat")
            
            if let content = response.result {
                let profileModel = ProfileModel(messageContent: content,
                                                hasError:       response.hasError,
                                                errorMessage:   response.errorMessage,
                                                errorCode:      response.errorCode)
                success(profileModel)
            }
        }
        
    }
    
}
