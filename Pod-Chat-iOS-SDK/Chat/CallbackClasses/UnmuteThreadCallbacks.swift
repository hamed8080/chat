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
    
    public class UnmuteThreadCallbacks: CallbackProtocol {
        func onResultCallback(uID: String, response: JSON, success: @escaping callbackTypeAlias, failure: @escaping callbackTypeAlias) {
            log.verbose("UnmuteThreadCallbacks", context: "Chat")
            
//            success(response)
            
            let hasError = response["hasError"].boolValue
            let errorMessage = response["errorMessage"].stringValue
            let errorCode = response["errorCode"].intValue
            
            if (!hasError) {
                let muteResult = Int(response["result"].stringValue) ?? 0
                let muteModel = MuteUnmuteThreadModel(threadId: muteResult, hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
                
                success(muteModel)
            }
            
        }
        
    }
    
}
