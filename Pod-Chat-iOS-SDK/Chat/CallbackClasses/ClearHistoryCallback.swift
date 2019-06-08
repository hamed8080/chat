//
//  ClearHistoryCallback.swift
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
    
    public class ClearHistoryCallback: CallbackProtocol {
        var mySendMessageParams: JSON
        init(parameters: JSON) {
            self.mySendMessageParams = parameters
        }
        func onResultCallback(uID: String, response: JSON, success: @escaping callbackTypeAlias, failure: @escaping callbackTypeAlias) {
            log.verbose("ClearHistoryCallback", context: "Chat")
            
            let hasError = response["hasError"].boolValue
            
            if (!hasError) {
                success(response)
            }
        }
        
    }
    
}
