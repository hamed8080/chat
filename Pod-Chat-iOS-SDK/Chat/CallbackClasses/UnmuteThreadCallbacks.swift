//
//  UnmuteThreadCallbacks.swift
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
    
    func responseOfUnmuteThread(withMessage message: ChatMessage) {
        /*
         *
         *
         *
         */
        log.verbose("Message of type 'UNMUTE_THREAD' recieved", context: "Chat")
        if Chat.map[message.uniqueId] != nil {
            let returnData: JSON = CreateReturnData(hasError:       false,
                                                    errorMessage:   "",
                                                    errorCode:      0,
                                                    result:         nil,
                                                    resultAsString: message.content,
                                                    contentCount:   nil,
                                                    subjectId:      message.subjectId)
                .returnJSON()
            
            let callback: CallbackProtocol = Chat.map[message.uniqueId]!
            callback.onResultCallback(uID: message.uniqueId, response: returnData, success: { (successJSON) in
                self.unmuteThreadCallbackToUser?(successJSON)
            }) { _ in }
            Chat.map.removeValue(forKey: message.uniqueId)
            
            // this functionality has beed deprecated
            /*
             let paramsToSend: JSON = ["threadIds": [threadId]]
             getThreads(params: paramsToSend, uniqueId: { _ in }) { (myResponse) in
             let myResponseModel: GetThreadsModel = myResponse as! GetThreadsModel
             let myResponseJSON: JSON = myResponseModel.returnDataAsJSON()
             let threads = myResponseJSON["result"]["threads"].arrayValue
             
             let result: JSON = ["thread": threads.first!]
             self.delegate?.threadEvents(type: "THREAD_UNMUTE", result: result)
             }
             */
        }
    }
    
    public class UnmuteThreadCallbacks: CallbackProtocol {
        func onResultCallback(uID:      String,
                              response: JSON,
                              success:  @escaping callbackTypeAlias,
                              failure:  @escaping callbackTypeAlias) {
            /*
             *
             *
             *
             */
            log.verbose("UnmuteThreadCallbacks", context: "Chat")
            
            if (!response["hasError"].boolValue) {
                let muteModel = MuteUnmuteThreadModel(threadId:     Int(response["result"].stringValue) ?? 0,
                                                      hasError:     response["hasError"].boolValue,
                                                      errorMessage: response["errorMessage"].stringValue,
                                                      errorCode:    response["errorCode"].intValue)
                success(muteModel)
            }
            
        }
        
    }
    
}
