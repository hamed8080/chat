//
//  UpdateChatProfileCallback.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 11/20/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import FanapPodAsyncSDK


extension Chat {
    
    /// UpdateChatProfile Response comes from server
    ///
    /// - Outputs:
    ///    - it doesn't have direct output,
    ///    - but on the situation where the response is valid,
    ///    - it will call the "onResultCallback" callback to updateChatProfile function (by using "userInfoCallbackToUser")
    @available(*,deprecated , message:"Removed in XX.XX.XX version.")
    func responseOfUpdateChatProfile(withMessage message: ChatMessage) {
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
                self.updateChatProfileCallbackToUser?(setProfileResponse)
            }) { _ in }
            Chat.map.removeValue(forKey: message.uniqueId)
        }
        
    }
    
    @available(*,deprecated , message:"Removed in XX.XX.XX version.")
    public class UpdateChatProfileCallback: CallbackProtocol {
        
        func onResultCallback(uID:      String,
                              response: CreateReturnData,
                              success:  @escaping callbackTypeAlias,
                              failure:  @escaping callbackTypeAlias) {
            log.verbose("SetProfileCallback", context: "Chat")
            
            if let content = response.result {
                let profileModel = ProfileResponse(messageContent:  content,
                                                   hasError:        response.hasError,
                                                   errorMessage:    response.errorMessage,
                                                   errorCode:       response.errorCode)
                success(profileModel)
            }
        }
        
    }
    
}
