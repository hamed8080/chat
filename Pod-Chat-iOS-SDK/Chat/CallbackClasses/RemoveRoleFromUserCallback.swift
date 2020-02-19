//
//  RemoveRoleFromUserCallback.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 10/1/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON
import SwiftyBeaver
import FanapPodAsyncSDK


extension Chat {
    
    func responseOfRemoveRoleFromUser(withMessage message: ChatMessage) {
        log.verbose("Message of type 'REMOVE_RULE_FROM_USER' recieved", context: "Chat")
        
        let returnData = CreateReturnData(hasError:         false,
                                          errorMessage:     "",
                                          errorCode:        0,
                                          result:           nil,
                                          resultAsArray:    nil,
                                          resultAsString:   message.content,
                                          contentCount:     nil,
                                          subjectId:        message.subjectId)
        
        let tRemoveAdminEM = ThreadEventModel(type:         ThreadEventTypes.THREAD_ADD_ADMIN,
                                              participants: nil,
                                              threads:      nil,
                                              threadId:     message.subjectId,
                                              senderId:     nil)
        delegate?.threadEvents(model: tRemoveAdminEM)
        let tLastActivityEM = ThreadEventModel(type:            ThreadEventTypes.THREAD_LAST_ACTIVITY_TIME,
                                               participants:    nil,
                                               threads:         nil,
                                               threadId:        message.subjectId,
                                               senderId:        nil)
        delegate?.threadEvents(model: tLastActivityEM)
        
        
        if Chat.map[message.uniqueId] != nil {
            let callback: CallbackProtocol = Chat.map[message.uniqueId]!
            callback.onResultCallback(uID: message.uniqueId, response: returnData, success: { (successJSON) in
                self.removeRoleFromUserCallbackToUser?(successJSON)
            }) { _ in }
            Chat.map.removeValue(forKey: message.uniqueId)
        }
    }
    
    // ToDo: put the data on the Cache if needed
    public class RemoveRoleFromUserCallback: CallbackProtocol {
        var mySendMessageParams: SendChatMessageVO
        init(parameters: SendChatMessageVO) {
            self.mySendMessageParams = parameters
        }
        
        func onResultCallback(uID:      String,
                              response: CreateReturnData,
                              success:  @escaping callbackTypeAlias,
                              failure:  @escaping callbackTypeAlias) {
            log.verbose("RemoveAdminCallback", context: "Chat")
            
            if let stringContent = response.resultAsString {
                let messageContent: [JSON] = stringContent.convertToJSON().arrayValue
                let userRoleModel = UserRolesModel(threadId:        mySendMessageParams.subjectId!,
                                                   messageContent:  messageContent,
                                                   hasError:        response.hasError,
                                                   errorMessage:    response.errorMessage,
                                                   errorCode:       response.errorCode)
                success(userRoleModel)
            }
        }
        
    }
    
}
