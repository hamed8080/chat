//
//  GetCurrentUserRolesCallback.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 11/8/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON
import SwiftyBeaver
import FanapPodAsyncSDK


extension Chat {
    
    func responseOfGetCurrentUserRoles(withMessage message: ChatMessage) {
        log.verbose("Message of type 'GET_CURRENT_USER_ROLES' recieved", context: "Chat")
        
        let returnData = CreateReturnData(hasError:         false,
                                          errorMessage:     "",
                                          errorCode:        0,
                                          result:           nil,
                                          resultAsArray:    message.content?.convertToJSON().arrayObject,
                                          resultAsString:   nil,
                                          contentCount:     nil,
                                          subjectId:        message.subjectId)
        
        if enableCache {
            if let response = returnData.resultAsArray as? [String], let threadId = message.subjectId {
                let currentUserRolesModel = GetCurrentUserRolesModel(messageContent:    response,
                                                                     hasError:          returnData.hasError,
                                                                     errorMessage:      returnData.errorMessage,
                                                                     errorCode:         returnData.errorCode)
                
                Chat.cacheDB.saveCurrentUserRoles(withRoles: currentUserRolesModel.userRoles, onThreadId: threadId)
            }
        }
        
        if Chat.map[message.uniqueId] != nil {
            let callback: CallbackProtocol = Chat.map[message.uniqueId]!
            callback.onResultCallback(uID:      message.uniqueId,
                                      response: returnData,
                                      success:  { (successJSON) in
                self.getCurrentUserRolesCallbackToUser?(successJSON)
            }) { _ in }
            Chat.map.removeValue(forKey: message.uniqueId)
        }
        
    }
    
    public class GetCurrentUserRolesCallbacks: CallbackProtocol {
        func onResultCallback(uID:      String,
                              response: CreateReturnData,
                              success:  @escaping callbackTypeAlias,
                              failure:  @escaping callbackTypeAlias) {
            log.verbose("GetCurrentUserRolesCallback", context: "Chat")
            
            if let content = response.resultAsArray as? [String] {
                let currentUserRolesModel = GetCurrentUserRolesModel(messageContent:    content,
                                                                     hasError:          response.hasError,
                                                                     errorMessage:      response.errorMessage,
                                                                     errorCode:         response.errorCode)
                success(currentUserRolesModel)
            }
        }
    }
    
}
