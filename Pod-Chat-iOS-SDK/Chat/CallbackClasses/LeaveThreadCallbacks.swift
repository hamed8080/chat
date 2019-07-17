//
//  LeaveThreadCallbacks.swift
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
    
    func responseOfLeaveThread(withMessage message: ChatMessage) {
        log.verbose("Message of type 'LEAVE_THREAD' recieved", context: "Chat")
        if Chat.map[message.uniqueId] != nil {
            let returnData: JSON = CreateReturnData(hasError:       false,
                                                    errorMessage:   "",
                                                    errorCode: 0,   result: message.content?.convertToJSON() ?? [:],
                                                    resultAsString: nil,
                                                    contentCount:   message.contentCount,
                                                    subjectId:      message.subjectId)
                .returnJSON()
            
            let callback: CallbackProtocol = Chat.map[message.uniqueId]!
            callback.onResultCallback(uID: message.uniqueId, response: returnData, success: { (successJSON) in
                self.leaveThreadCallbackToUser?(successJSON)
            }) { _ in }
            Chat.map.removeValue(forKey: message.uniqueId)
        }
        
        // this functionality has beed deprecated
        /*
         let threadIds = messageContent["id"].intValue
         let paramsToSend: JSON = ["threadIds": threadIds]
         getThreads(params: paramsToSend, uniqueId: { _ in }) { (response) in
         
         let responseModel: GetThreadsModel = response as! GetThreadsModel
         let responseJSON: JSON = responseModel.returnDataAsJSON()
         let threads = responseJSON["result"]["threads"].array
         
         if let myThreads = threads {
         let result: JSON = ["thread": myThreads[0]]
         self.delegate?.threadEvents(type: "THREAD_LEAVE_PARTICIPANT", result: result)
         self.delegate?.threadEvents(type: "THREAD_LAST_ACTIVITY_TIME", result: result)
         } else {
         let result: JSON = ["threadId": threadId]
         self.delegate?.threadEvents(type: "THREAD_LEAVE_PARTICIPANT", result: result)
         }
         
         }
         */
    }
    
    public class LeaveThreadCallbacks: CallbackProtocol {
        func onResultCallback(uID: String, response: JSON, success: @escaping callbackTypeAlias, failure: @escaping callbackTypeAlias) {
            /*
             *
             *
             */
            log.verbose("LeaveThreadCallbacks", context: "Chat")
            
            if (!response["hasError"].boolValue) {
                let leaveThreadModel = CreateThreadModel(messageContent:    response["result"],
                                                         hasError:          response["hasError"].boolValue,
                                                         errorMessage:      response["errorMessage"].stringValue,
                                                         errorCode:         response["errorCode"].intValue)
                
                success(leaveThreadModel)
            }
        }
    }
    
}
