//
//  PinMessageCallback.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 10/29/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyBeaver
import FanapPodAsyncSDK


extension Chat {
    
    /// PinMessage Response comes from server
    ///
    /// - Outputs:
    ///    - it doesn't have direct output,
    ///    - but on the situation where the response is valid,
    ///    - it will call the "onResultCallback" callback to PpnMessage function (by using "pinMessageCallbackToUser")
    @available(*,deprecated , message:"Removed in 0.10.5.0 version")
    func responseOfPinMessage(withMessage message: ChatMessage) {
        log.verbose("Message of type 'PIN_MESSAGE' recieved", context: "Chat")
        
        let returnData = CreateReturnData(hasError:         false,
                                          errorMessage:     "",
                                          errorCode:        0,
                                          result:           message.content?.convertToJSON() ?? [:],
                                          resultAsArray:    nil,
                                          resultAsString:   nil,
                                          contentCount:     nil,
                                          subjectId:        message.subjectId)
        
        if let messageContent = message.content?.convertToJSON() {
            let threadEventModel = ThreadEventModel(type: ThreadEventTypes.MESSAGE_PIN,
                                                    participants:   nil,
                                                    threads:        nil,
                                                    threadId:       message.subjectId,
                                                    senderId:       nil,
                                                    unreadCount:    messageContent["unreadCount"].int,
                                                    pinMessage:     PinUnpinMessage(pinUnpinContent: messageContent))
            delegate?.threadEvents(model: threadEventModel)
        }
        
        if enableCache {
            if let thId = message.subjectId {
                if let pinMessageJSON = message.content?.convertToJSON() {
                    Chat.cacheDB.savePinMessage(threadId: thId, withPinMessageObject: PinUnpinMessage(pinUnpinContent: pinMessageJSON))
//                    Chat.cacheDB.savePinCMMessageEntity(threadId: thId, withPinMessageObject: PinUnpinMessage(pinUnpinContent: pinMessageJSON))
                }
            }
        }
        
        if Chat.map[message.uniqueId] != nil {
            let callback: CallbackProtocol = Chat.map[message.uniqueId]!
            callback.onResultCallback(uID:      message.uniqueId,
                                      response: returnData,
                                      success:  { (successJSON) in
                self.pinMessageCallbackToUser?(successJSON)
            }) { _ in }
            Chat.map.removeValue(forKey: message.uniqueId)
        }
    }
    
    @available(*,deprecated , message:"Removed in 0.10.5.0 version")
    public class PinMessageCallbacks: CallbackProtocol {
        func onResultCallback(uID:      String,
                              response: CreateReturnData,
                              success:  @escaping callbackTypeAlias,
                              failure:  @escaping callbackTypeAlias) {
            log.verbose("PinMessageCallbacks", context: "Chat")
            
            if let content = response.result {
                let pinMessageModel = PinUnpinMessageResponse(pinUnpinModel:    PinUnpinMessage(pinUnpinContent: content),
                                                              hasError:         response.hasError,
                                                              errorMessage:     response.errorMessage,
                                                              errorCode:        response.errorCode)

                success(pinMessageModel)
            }
            
        }
        
    }
    
}
