//
//  GetAllUnreadMessagesCountCallbacks.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 12/25/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON
import SwiftyBeaver
import FanapPodAsyncSDK


extension Chat {
    
    func responseOfAllUnreadMessageCount(withMessage message: ChatMessage) {
        log.verbose("Message of type 'ALL_UNREAD_MESSAGE_COUNT' recieved", context: "Chat")
        
        let returnData = CreateReturnData(hasError:         false,
                                          errorMessage:     "",
                                          errorCode:        0,
                                          result:           nil,
                                          resultAsArray:    nil,
                                          resultAsString:   message.content,
                                          contentCount:     message.contentCount,
                                          subjectId:        message.subjectId)
        
        if Chat.map[message.uniqueId] != nil {
            let callback: CallbackProtocol = Chat.map[message.uniqueId]!
            callback.onResultCallback(uID:      message.uniqueId,
                                      response: returnData,
                                      success:  { (successJSON) in
                self.getAllUnreadMessagesCountCallbackToUser?(successJSON)
            }) { _ in }
            Chat.map.removeValue(forKey: message.uniqueId)
        }
        
    }
    
    
    public class GetAllUnreadMessagesCountCallbacks: CallbackProtocol {
        func onResultCallback(uID:      String,
                              response: CreateReturnData,
                              success:  @escaping callbackTypeAlias,
                              failure:  @escaping callbackTypeAlias) {
            log.verbose("GetAllUnreadMessagesCountCallbacks", context: "Chat")
            
            if let unreadCountStr = response.resultAsString, let unreadCount = Int(unreadCountStr) {
                let unreadMessageCountModel = UnreadMessageCountModel(unreadCount:    unreadCount,
                                                                      hasError:       false,
                                                                      errorMessage:   "",
                                                                      errorCode:      0)
                success(unreadMessageCountModel)
            }
        }
        
    }
    
}
