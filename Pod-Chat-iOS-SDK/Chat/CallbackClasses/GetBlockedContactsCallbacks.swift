//
//  GetBlockedContactsCallbacks.swift
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
     * GetBlockContact Response comes from server
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
     *          it will call the "onResultCallback" callback to getBlockedContacts function (by using "blockCallbackToUser")
     *
     */
    func responseOfGetBlockContact(withMessage message: ChatMessage) {
        /*
         *  -> check if we have saves the message uniqueId on the "map" property
         *      -> if yes: (means we send this request and waiting for the response of it)
         *          -> create the "CreateReturnData" variable
         *          -> check if Cache is enabled by the user
         *              -> if yes, save the income Data to the Cache
         *          -> call the "onResultCallback" which will send callback to getBlockedContacts function (by using "blockCallbackToUser")
         *
         */
        log.verbose("Message of type 'GET_BLOCKED' recieved", context: "Chat")
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
                self.getBlockedCallbackToUser?(successJSON)
            }) { _ in }
            Chat.map.removeValue(forKey: message.uniqueId)
        }
        
    }
    
    
    public class GetBlockedContactsCallbacks: CallbackProtocol {
        var sendParams: SendChatMessageVO
        init(parameters: SendChatMessageVO) {
            self.sendParams = parameters
        }
        func onResultCallback(uID:      String,
                              response: JSON,
                              success:  @escaping callbackTypeAlias,
                              failure:  @escaping callbackTypeAlias) {
            /*
             *  -> check if response hasError or not
             *      -> if yes, create the "GetBlockedContactListModel"
             *      -> send the "GetBlockedContactListModel" as a callback
             *
             */
            if (!response["hasError"].boolValue) {
                let content = sendParams.content.convertToJSON()
                let getBlockedModel = GetBlockedContactListModel(messageContent:    response["result"].arrayValue,
                                                                 contentCount:      response["contentCount"].intValue,
                                                                 count:             content["count"].intValue,
                                                                 offset:            content["offset"].intValue,
                                                                 hasError:          response["hasError"].boolValue,
                                                                 errorMessage:      response["errorMessage"].stringValue,
                                                                 errorCode:         response["errorCode"].intValue)
                success(getBlockedModel)
            }
            
        }
    }
    
}
