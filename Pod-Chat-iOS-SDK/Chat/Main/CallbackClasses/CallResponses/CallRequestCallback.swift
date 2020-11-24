//
//  CallRequestCallback.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 9/4/1399 AP.
//  Copyright © 1399 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON
import SwiftyBeaver
import FanapPodAsyncSDK


extension Chat {
    
    /// CallRequst comes from server
    ///
    /// - Outputs:
    ///    - it doesn't have any output,
    func createCallRequestComes(withMessage message: ChatMessage) {
        log.verbose("Message of type 'CALL_REQUEST' recieved", context: "Chat")
        
        let returnData = CreateReturnData(hasError:         false,
                                          errorMessage:     "",
                                          errorCode:        0,
                                          result:           message.content?.convertToJSON(),
                                          resultAsArray:    nil,
                                          resultAsString:   nil,
                                          contentCount:     message.contentCount,
                                          subjectId:        message.subjectId)
        
        // ToDo: send CallRequest Event
        
    }
    
    
    
    
    public class CallRequestCallback: CallbackProtocol {
        
        func onResultCallback(uID:      String,
                              response: CreateReturnData,
                              success:  @escaping callbackTypeAlias,
                              failure:  @escaping callbackTypeAlias) {
            log.verbose("CallRequestCallback", context: "Chat")
            
            if let result = response.result {
                
                // check the result to see if it is Accept or Reject or Start Response
                
                // response of type 72 (reject)
                if let isRejected = result["isRejected"].bool {
                    let res = RejectCallResponse(messageContent:    result,
                                                 isRejected:        isRejected,
                                                 hasError:          response.hasError,
                                                 errorMessage:      response.errorMessage,
                                                 errorCode:         response.errorCode)
                    success(res)
                }
                // response of type 73 (deliver)
                else if let isDelivered = result["isDelivered"].bool {
                    let res = DeliverCallResponse(messageContent:   result,
                                                  isDelivered:      isDelivered,
                                                  hasError:         response.hasError,
                                                  errorMessage:     response.errorMessage,
                                                  errorCode:        response.errorCode)
                    success(res)
                }
                // response of type 74 (start)
                else if let _ = result["callName"].string {
                    let res = CallStartResponse(messageContent: result,
                                                hasError:       response.hasError,
                                                errorMessage:   response.errorMessage,
                                                errorCode:      response.errorCode)
                    success(res)
                }
                
            }
            
        }
        
    }
    
}
