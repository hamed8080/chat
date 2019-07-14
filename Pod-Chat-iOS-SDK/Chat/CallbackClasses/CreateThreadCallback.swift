//
//  CreateThreadCallback.swift
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
    
    func chatDelegateCreateThread(createThread: JSON) {
        let hasError = createThread["hasError"].boolValue
        let errorMessage = createThread["errorMessage"].stringValue
        let errorCode = createThread["errorCode"].intValue
        
        if (!hasError) {
            let resultData: JSON = createThread["result"]
            
            let createThreadModel = CreateThreadModel(messageContent: resultData, hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
            
            delegate?.threadEvents(type: ThreadEventTypes.THREAD_NEW, result: createThreadModel)
        }
    }
    
    public class CreateThreadCallback: CallbackProtocol {
        var mySendMessageParams: SendChatMessageVO
        init(parameters: SendChatMessageVO) {
            self.mySendMessageParams = parameters
        }
        func onResultCallback(uID: String, response: JSON, success: @escaping callbackTypeAlias, failure: @escaping callbackTypeAlias) {
            log.verbose("CreateThreadCallback", context: "Chat")
            
            let hasError = response["hasError"].boolValue
            let errorMessage = response["errorMessage"].stringValue
            let errorCode = response["errorCode"].intValue
            
            if (!hasError) {
                let resultData: JSON = response["result"]
                let createThreadModel = CreateThreadModel(messageContent: resultData, hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
                
                success(createThreadModel)
                
            }
        }
        
    }
    
}
