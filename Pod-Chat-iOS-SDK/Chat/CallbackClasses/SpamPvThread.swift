//
//  SpamPvThread.swift
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
    
//    func responseOfSpamPvThread(withMessage message: ChatMessage) {
//        /*
//         *
//         *
//         */
//        log.verbose("Message of type 'SPAM_PV_THREAD' recieved", context: "Chat")
//        if Chat.map[message.uniqueId] != nil {
//            let returnData = CreateReturnData(hasError:         false,
//                                              errorMessage:     "",
//                                              errorCode:        0,
//                                              result:           message.content?.convertToJSON() ?? [:],
//                                              resultAsArray:    nil,
//                                              resultAsString:   nil,
//                                              contentCount:     nil,
//                                              subjectId:        message.subjectId)
//
//            let callback: CallbackProtocol = Chat.map[message.uniqueId]!
//            callback.onResultCallback(uID:      message.uniqueId,
//                                      response: returnData,
//                                      success:  { (successJSON) in
//                self.spamPvThreadCallbackToUser?(successJSON)
//            }) { _ in }
//            Chat.map.removeValue(forKey: message.uniqueId)
//        }
//    }
    
    // ToDo: convert the JSON output to Model
    public class SpamPvThread: CallbackProtocol {
        func onResultCallback(uID:      String,
                              response: CreateReturnData,
                              success:  @escaping callbackTypeAlias,
                              failure:  @escaping callbackTypeAlias) {
            /*
             *
             *
             *
             */
            if let result = response.result {
                
                // leaveThreadResponse
                if let _ = result["coreUserId"].int {
                    let leaveThreadModel = ThreadModel(messageContent:    response.result!,
                                                       hasError:          response.hasError,
                                                       errorMessage:      response.errorMessage,
                                                       errorCode:         response.errorCode)
                    success(leaveThreadModel)
                }
                // blocked Response
                else if let _ = result["id"].int {
                    let blockUserModel = BlockedContactModel(messageContent:    response.result!,
                                                             hasError:          response.hasError,
                                                             errorMessage:      response.errorMessage,
                                                             errorCode:         response.errorCode)
                    success(blockUserModel)
                }
            // ClearHistory Response
            } else if let result = response.resultAsString {
                let clearHistoryModel = ClearHistoryModel(threadId:     Int(result) ?? 0,
                                                          hasError:     response.hasError,
                                                          errorMessage: response.errorMessage,
                                                          errorCode:    response.errorCode)
                success(clearHistoryModel)
            }
            
        }
    }
    
}
