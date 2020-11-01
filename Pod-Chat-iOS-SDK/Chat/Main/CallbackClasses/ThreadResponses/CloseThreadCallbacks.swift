//
//  CloseThreadCallbacks.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 8/11/1399 AP.
//  Copyright © 1399 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON
import SwiftyBeaver
import FanapPodAsyncSDK


extension Chat {
    
    /// CloseThread Response comes from server
    ///
    /// - Outputs:
    ///    - it doesn't have direct output,
    ///    - but on the situation where the response is valid,
    ///    - it will call the "onResultCallback" callback to closeThread function (by using "closeThreadCallbackToUser")
    func responseOfCloseThread(withMessage message: ChatMessage) {
        log.verbose("Message of type 'CLOSE_THREAD' recieved", context: "Chat")
        
        let tClosEM = ThreadEventModel(type:            ThreadEventTypes.THREAD_CLOSED,
                                       participants:    nil,
                                       threads:         nil,
                                       threadId:        message.subjectId,
                                       senderId:        nil,
                                       unreadCount:     message.content?.convertToJSON()["unreadCount"].int,
                                       pinMessage:      nil)
        delegate?.threadEvents(model: tClosEM)
        
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
                self.closeThreadCallbackToUser?(successJSON)
            }) { _ in }
            Chat.map.removeValue(forKey: message.uniqueId)
        }
    }
    
    public class CloseThreadCallbacks: CallbackProtocol {
        func onResultCallback(uID:      String,
                              response: CreateReturnData,
                              success:  @escaping callbackTypeAlias,
                              failure:  @escaping callbackTypeAlias) {
            log.verbose("CloseThreadCallbacks", context: "Chat")
            
            if let stringContent = response.resultAsString {
                let closeModel = CloseThreadResponse(threadId:      Int(stringContent) ?? 0,
                                                     hasError:      response.hasError,
                                                     errorMessage:  response.errorMessage,
                                                     errorCode:     response.errorCode)
                
                success(closeModel)
            }
            
        }
        
    }
    
}
