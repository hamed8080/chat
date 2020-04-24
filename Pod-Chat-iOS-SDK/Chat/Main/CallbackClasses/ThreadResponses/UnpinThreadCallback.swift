//
//  UnpinThreadCallback.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 10/7/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyBeaver
import FanapPodAsyncSDK


extension Chat {
    
    /// UnpinThread Response comes from server
    ///
    /// - Outputs:
    ///    - it doesn't have direct output,
    ///    - but on the situation where the response is valid,
    ///    - it will call the "onResultCallback" callback to unpinThread function (by using "unpinThreadCallbackToUser")
    func responseOfUnpinThread(withMessage message: ChatMessage) {
        log.verbose("Message of type 'UNPIN_THREAD' recieved", context: "Chat")
        
        let tUnpinEM = ThreadEventModel(type:           ThreadEventTypes.THREAD_UNPIN,
                                        participants:   nil,
                                        threads:        nil,
                                        threadId:       message.subjectId,
                                        senderId:       nil,
                                        unreadCount:    message.content?.convertToJSON()["unreadCount"].int,
                                        pinMessage:     nil)
        delegate?.threadEvents(model: tUnpinEM)
        
        if enableCache {
            if let thId = message.subjectId {
                Chat.cacheDB.savePinUnpinCMConversationEntity(withThreadId: thId, isPinned: false)
            }
        }
        
        let returnData = CreateReturnData(hasError:         false,
                                          errorMessage:     "",
                                          errorCode:        0,
                                          result:           nil,
                                          resultAsArray:    nil,
                                          resultAsString:   message.content,
                                          contentCount:     nil,
                                          subjectId:        message.subjectId)
        
        if Chat.map[message.uniqueId] != nil {
            let callback: CallbackProtocol = Chat.map[message.uniqueId]!
            callback.onResultCallback(uID:      message.uniqueId,
                                      response: returnData,
                                      success:  { (successJSON) in
                self.unpinThreadCallbackToUser?(successJSON)
            }) { _ in }
            Chat.map.removeValue(forKey: message.uniqueId)
        }
    }
    
    public class UnpinThreadCallbacks: CallbackProtocol {
        func onResultCallback(uID:      String,
                              response: CreateReturnData,
                              success:  @escaping callbackTypeAlias,
                              failure:  @escaping callbackTypeAlias) {
            log.verbose("UnpinThreadCallbacks", context: "Chat")
            
            if let stringContent = response.resultAsString {
                let unpinModel = PinUnpinThreadResponse(threadId:       Int(stringContent) ?? 0,
                                                        hasError:       response.hasError,
                                                        errorMessage:   response.errorMessage,
                                                        errorCode:      response.errorCode)
                
                success(unpinModel)
            }
            
        }
        
    }
    
}
