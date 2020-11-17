//
//  StatusPingCallback.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 6/22/1399 AP.
//  Copyright © 1399 Mahyar Zhiani. All rights reserved.
//

import Foundation
import FanapPodAsyncSDK


extension Chat {
    
    /// StatusPing Response comes from server
    ///
    /// - Outputs:
    ///    - it doesn't have direct output,
    ///    - but on the situation where the response is valid,
    ///    - it will call the "onResultCallback" callback to statusPing function (by using "statusPingCallbackToUser")
    func responseOfStatusPing(withMessage message: ChatMessage) {
        log.verbose("Message of type 'STATUS_PING' recieved", context: "Chat")
        
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
                                      success:  { (statusPingResponse) in
                // here has to send callback to statusPing function
                self.statusPingCallbackToUser?(statusPingResponse)
            }) { _ in }
            Chat.map.removeValue(forKey: message.uniqueId)
        }
        
    }
    
    public class StatusPingCallback: CallbackProtocol {
        
        func onResultCallback(uID:      String,
                              response: CreateReturnData,
                              success:  @escaping callbackTypeAlias,
                              failure:  @escaping callbackTypeAlias) {
            log.verbose("StatusPingCallback", context: "Chat")
            
            if let _ = response.result {
                
                // ToDo: what to do with statusPing response
                
//                let profileModel = ProfileResponse(messageContent:  content,
//                                                   hasError:        response.hasError,
//                                                   errorMessage:    response.errorMessage,
//                                                   errorCode:       response.errorCode)
//                success(profileModel)
            }
        }
        
    }
    
}
