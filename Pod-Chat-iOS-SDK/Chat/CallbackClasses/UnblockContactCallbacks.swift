//
//  UnblockContactCallbacks.swift
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
    
    /*
     * UnblockContact Response comes from server
     *
     *  send Event to client if needed!
     *  call the "onResultCallback"
     *
     *  + Access:   - private
     *  + Inputs:
     *      - message:      ChatMessage
     *  + Outputs:
     *      - it doesn't have direct output,
     *          but on the situation where the response is valid,
     *          it will call the "onResultCallback" callback to unblockContact function (by using "unblockCallbackToUser")
     *
     */
    func responseOfUnblockContact(withMessage message: ChatMessage) {
        /*
         *  -> check if we have saves the message uniqueId on the "map" property
         *      -> if yes: (means we send this request and waiting for the response of it)
         *          -> create the "CreateReturnData" variable
         *          -> check if Cache is enabled by the user
         *              -> if yes, save the income Data to the Cache
         *          -> call the "onResultCallback" which will send callback to unblockContact function (by using "unblockCallbackToUser")
         *
         */
        log.verbose("Message of type 'UNBLOCK' recieved", context: "Chat")
        if Chat.map[message.uniqueId] != nil {
            let returnData: JSON = CreateReturnData(hasError:       false,
                                                    errorMessage:   "",
                                                    errorCode:      0,
                                                    result:         message.content?.convertToJSON() ?? [:],
                                                    resultAsString: nil,
                                                    contentCount:   message.contentCount,
                                                    subjectId:      message.subjectId)
                .returnJSON()
            
            let callback: CallbackProtocol = Chat.map[message.uniqueId]!
            callback.onResultCallback(uID:      message.uniqueId,
                                      response: returnData,
                                      success:  { (successJSON) in
                self.unblockCallbackToUser?(successJSON)
            }) { _ in }
            Chat.map.removeValue(forKey: message.uniqueId)
        }
        
    }
    
    public class UnblockContactCallbacks: CallbackProtocol {
        func onResultCallback(uID:      String,
                              response: JSON,
                              success:  @escaping callbackTypeAlias,
                              failure:  @escaping callbackTypeAlias) {
            /*
             *  -> check if response has result or not
             *      -> if yes, create the "BlockedContactModel"
             *      -> send the "BlockedContactModel" as a callback
             *
             */
            if (response["result"] != JSON.null) {
                let unblockUserModel = BlockedContactModel(messageContent:  response["result"],
                                                           hasError:        response["hasError"].boolValue,
                                                           errorMessage:    response["errorMessage"].stringValue,
                                                           errorCode:       response["errorCode"].intValue)
                success(unblockUserModel)
            }
        }
    }
    
}
