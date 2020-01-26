//
//  UnpinMessageCallback.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 10/29/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyBeaver
import FanapPodAsyncSDK


extension Chat {
    
    func responseOfUnpinMessage(withMessage message: ChatMessage) {
        log.verbose("Message of type 'UNPIN_MESSAGE' recieved", context: "Chat")
        
//        let tPinEM = ThreadEventModel(type:            ThreadEventTypes.THREAD_PIN,
//                                      participants:    nil,
//                                      threads:         nil,
//                                      threadId:        message.subjectId,
//                                      senderId:        nil)
//        delegate?.threadEvents(model: tPinEM)
        
        let returnData = CreateReturnData(hasError:         false,
                                          errorMessage:     "",
                                          errorCode:        0,
                                          result:           message.content?.convertToJSON() ?? [:],
                                          resultAsArray:    nil,
                                          resultAsString:   nil,
                                          contentCount:     nil,
                                          subjectId:        message.subjectId)
        
        if enableCache {
            if let thId = message.subjectId {
                Chat.cacheDB.deletePinMessageFromCMConversationEntity(threadId: thId)
            }
        }
        
        if Chat.map[message.uniqueId] != nil {
            let callback: CallbackProtocol = Chat.map[message.uniqueId]!
            callback.onResultCallback(uID:      message.uniqueId,
                                      response: returnData,
                                      success:  { (successJSON) in
                self.unpinMessageCallbackToUser?(successJSON)
            }) { _ in }
            Chat.map.removeValue(forKey: message.uniqueId)
        }
    }
    
    public class UnpinMessageCallbacks: CallbackProtocol {
        func onResultCallback(uID:      String,
                              response: CreateReturnData,
                              success:  @escaping callbackTypeAlias,
                              failure:  @escaping callbackTypeAlias) {
            
            log.verbose("UnpinMessageCallbacks", context: "Chat")
            
            if let content = response.result {
                let pinMessageModel = PinUnpinMessageModel(pinUnpinModel:   PinUnpinMessage(pinUnpinContent: content),
                                                           hasError:        response.hasError,
                                                           errorMessage:    response.errorMessage,
                                                           errorCode:       response.errorCode)

                success(pinMessageModel)
            }

            
        }
        
    }
    
}
