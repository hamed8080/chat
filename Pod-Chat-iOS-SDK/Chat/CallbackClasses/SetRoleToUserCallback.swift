//
//  SetRoleToUserCallback.swift
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
    
    public class SetRoleToUserCallback: CallbackProtocol {
        var mySendMessageParams: JSON
        init(parameters: JSON) {
            self.mySendMessageParams = parameters
        }
        func onResultCallback(uID: String, response: JSON, success: @escaping callbackTypeAlias, failure: @escaping callbackTypeAlias) {
            log.verbose("GetAdminListCallback", context: "Chat")
            
            let hasError = response["hasError"].boolValue
            let errorMessage = response["errorMessage"].stringValue
            let errorCode = response["errorCode"].intValue
            
            if (!hasError) {
                /*
                 let messageContent: [JSON] = response["result"].arrayValue
                 let setRoleModel = SetRolesModel(messageContent: messageContent, hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
                 
                 success(setRoleModel)
                 */
                
                success(response)
            }
        }
        
    }
    
}
