//
//  SpamPrivateThread.swift
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
    
    
    public class SpamPrivateThread: CallbackProtocol {
        func onResultCallback(uID:      String,
                              response: CreateReturnData,
                              success:  @escaping callbackTypeAlias,
                              failure:  @escaping callbackTypeAlias) {
            log.verbose("SpamPvThreadCallback", context: "Chat")
            
            if let result = response.result {
                
                // leaveThreadResponse
                if let _ = result["coreUserId"].int {
                    let leaveThreadModel = ThreadResponse(messageContent:   response.result!,
                                                          hasError:         response.hasError,
                                                          errorMessage:     response.errorMessage,
                                                          errorCode:        response.errorCode)
                    success(leaveThreadModel)
                }
                // blocked Response
                else if let _ = result["id"].int {
                    let blockUserModel = BlockUnblockResponse(messageContent:   response.result!,
                                                              hasError:         response.hasError,
                                                              errorMessage:     response.errorMessage,
                                                              errorCode:        response.errorCode)
                    success(blockUserModel)
                }
            // ClearHistory Response
            } else if let result = response.resultAsString {
                let clearHistoryModel = ClearHistoryResponse(threadId:      Int(result) ?? 0,
                                                             hasError:      response.hasError,
                                                             errorMessage:  response.errorMessage,
                                                             errorCode:     response.errorCode)
                success(clearHistoryModel)
            }
            
        }
    }
    
}
