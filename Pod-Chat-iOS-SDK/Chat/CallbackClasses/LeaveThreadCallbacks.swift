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
    
    public class LeaveThreadCallbacks: CallbackProtocol {
        func onResultCallback(uID: String, response: JSON, success: @escaping callbackTypeAlias, failure: @escaping callbackTypeAlias) {
            log.verbose("LeaveThreadCallbacks", context: "Chat")
            
            let hasError = response["hasError"].boolValue
            let errorMessage = response["errorMessage"].stringValue
            let errorCode = response["errorCode"].intValue
            
            if (!hasError) {
                let resultData: JSON = response["result"]
                
                let leaveThreadModel = CreateThreadModel(messageContent: resultData, hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
                
                success(leaveThreadModel)
            }
        }
    }
    
}
