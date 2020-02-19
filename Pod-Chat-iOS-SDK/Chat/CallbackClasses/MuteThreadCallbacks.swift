//
//  MuteThreadCallbacks.swift
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
    
    func responseOfMuteThread(withMessage message: ChatMessage) {
        log.verbose("Message of type 'MUTE_THREAD' recieved", context: "Chat")
        
        let tMuteEM = ThreadEventModel(type:            ThreadEventTypes.THREAD_MUTE,
                                       participants:    nil,
                                       threads:         nil,
                                       threadId:        message.subjectId,
                                       senderId:        nil)
        delegate?.threadEvents(model: tMuteEM)
        
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
                self.muteThreadCallbackToUser?(successJSON)
            }) { _ in }
            Chat.map.removeValue(forKey: message.uniqueId)
        }
    }
    
    public class MuteThreadCallbacks: CallbackProtocol {
        func onResultCallback(uID:      String,
                              response: CreateReturnData,
                              success:  @escaping callbackTypeAlias,
                              failure:  @escaping callbackTypeAlias) {
            log.verbose("MuteThreadCallbacks", context: "Chat")
            
            if let stringContent = response.resultAsString {
                let muteModel = MuteUnmuteThreadModel(threadId:     Int(stringContent) ?? 0,
                                                      hasError:     response.hasError,
                                                      errorMessage: response.errorMessage,
                                                      errorCode:    response.errorCode)
                
                success(muteModel)
            }
            
        }
        
    }
    
}
