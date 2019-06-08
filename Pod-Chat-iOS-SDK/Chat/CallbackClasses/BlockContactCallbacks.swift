//
//  BlockContactCallbacks.swift
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
    
    public class BlockContactCallbacks: CallbackProtocol {
        func onResultCallback(uID: String, response: JSON, success: @escaping callbackTypeAlias, failure: @escaping callbackTypeAlias) {
            
            let hasError = response["hasError"].boolValue
            let errorMessage = response["errorMessage"].stringValue
            let errorCode = response["errorCode"].intValue
            
            if response["result"] != JSON.null {
                let messageContent = response["result"]
                
                let blockUserModel = BlockedContactModel(messageContent: messageContent, hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
                
                success(blockUserModel)
            }
        }
    }
    
}
