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
    
    func responseOfSetRoleToUser(withMessage message: ChatMessage) {
        /*
         *
         *
         *
         */
        log.verbose("Message of type 'SET_RULE_TO_USER' recieved", context: "Chat")
        if Chat.map[message.uniqueId] != nil {
            let returnData: JSON = CreateReturnData(hasError:       false,
                                                    errorMessage:   "",
                                                    errorCode:      0,
                                                    result:         nil,
                                                    resultAsString: message.content,
                                                    contentCount:   nil,
                                                    subjectId:      message.subjectId)
                .returnJSON()
            
            let callback: CallbackProtocol = Chat.map[message.uniqueId]!
            callback.onResultCallback(uID: message.uniqueId, response: returnData, success: { (successJSON) in
                self.setRoleToUserCallbackToUser?(successJSON)
            }) { _ in }
            Chat.map.removeValue(forKey: message.uniqueId)
        }
    }
    
    // ToDo: convert the JSON output to Model
    // ToDo: put the data on the Cache if needed
    public class SetRoleToUserCallback: CallbackProtocol {
        
        var mySendMessageParams: SendChatMessageVO
        init(parameters: SendChatMessageVO) {
            self.mySendMessageParams = parameters
        }
        
        func onResultCallback(uID: String, response: JSON, success: @escaping callbackTypeAlias, failure: @escaping callbackTypeAlias) {
            log.verbose("GetAdminListCallback", context: "Chat")
            
            if (!response["hasError"].boolValue) {
                
                let messageContent: [JSON] = response["result"].stringValue.convertToJSON().arrayValue
                let userRoleModel = UserRolesModel(threadId:        mySendMessageParams.subjectId!,
                                                   messageContent:  messageContent,
                                                   hasError:        response["hasError"].boolValue,
                                                   errorMessage:    response["errorMessage"].stringValue,
                                                   errorCode:       response["errorCode"].intValue)
//                print("\n\n response:\n\(response)")
//                print("\n\n\n messageContent:\n\(messageContent)")
//                print("\n\nuserRoleModel:\n\(userRoleModel.returnDataAsJSON())\n\n\n\n\n\n")
//                success(setRoleModel)
                
                success(response)
            }
        }
        
    }
    
}
