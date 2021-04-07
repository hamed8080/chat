//
//  UnblockCallbacks.swift
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
    
    /// Unblock Response comes from server
    ///
    /// - Outputs:
    ///    - it doesn't have direct output,
    ///    - but on the situation where the response is valid,
    ///    - it will call the "onResultCallback" callback to unblock function (by using "unblockUserCallbackToUser")
    @available(*,deprecated , message:"Removed in XX.XX.XX version.")
    func responseOfUnblockContact(withMessage message: ChatMessage) {
        log.verbose("Message of type 'UNBLOCK' recieved", context: "Chat")
        
        if let contentAsJSON = message.content?.convertToJSON() {
            let unblockModel = BlockedUser(messageContent: contentAsJSON)
            let unblockEM = UserEventModel(type: UserEventTypes.UNBLOCK, blockModel: unblockModel, threadId: message.subjectId)
            delegate?.userEvents(model: unblockEM)
        }
        
        let returnData = CreateReturnData(hasError:         false,
                                          errorMessage:     "",
                                          errorCode:        0,
                                          result:           message.content?.convertToJSON() ?? [:],
                                          resultAsArray:    nil,
                                          resultAsString:   nil,
                                          contentCount:     message.contentCount,
                                          subjectId:        message.subjectId)
        
        if Chat.map[message.uniqueId] != nil {
            let callback: CallbackProtocol = Chat.map[message.uniqueId]!
            callback.onResultCallback(uID:      message.uniqueId,
                                      response: returnData,
                                      success:  { (successJSON) in
                self.unblockUserCallbackToUser?(successJSON)
            }) { _ in }
            Chat.map.removeValue(forKey: message.uniqueId)
        }
        
    }
    
    @available(*,deprecated , message:"Removed in XX.XX.XX version.")
    public class UnblockCallbacks: CallbackProtocol {
        func onResultCallback(uID:      String,
                              response: CreateReturnData,
                              success:  @escaping callbackTypeAlias,
                              failure:  @escaping callbackTypeAlias) {
            log.verbose("UnblockContactCallback", context: "Chat")
            
            if let content = response.result {
                let unblockUserModel = BlockUnblockResponse(messageContent: content,
                                                            hasError:       response.hasError,
                                                            errorMessage:   response.errorMessage,
                                                            errorCode:      response.errorCode)
                success(unblockUserModel)
            }
        }
    }
    
}
