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
        var mySendMessageParams: SendChatMessageVO
        init(parameters: SendChatMessageVO) {
            self.mySendMessageParams = parameters
        }
        func onResultCallback(uID: String, response: JSON, success: @escaping callbackTypeAlias, failure: @escaping callbackTypeAlias) {
            log.verbose("GetAdminListCallback", context: "Chat")
            
            let hasError = response["hasError"].boolValue
            let errorMessage = response["errorMessage"].stringValue
            let errorCode = response["errorCode"].intValue
            
            if (!hasError) {
                
                let messageContentStr: String = response["result"].stringValue
                let messageContent: [JSON] = messageContentStr.convertToJSON().arrayValue
                let userRoleModel = UserRolesModel(threadId: mySendMessageParams.subjectId!, messageContent: messageContent, hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
//                print("\n\n response:\n\(response)")
//                print("\n\n\n messageContent:\n\(messageContent)")
//                print("\n\nuserRoleModel:\n\(userRoleModel.returnDataAsJSON())\n\n\n\n\n\n")
//                success(setRoleModel)
 
                
                success(response)
            }
        }
        
    }
    
}
