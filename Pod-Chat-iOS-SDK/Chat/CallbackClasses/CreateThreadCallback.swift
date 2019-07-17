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
    
    func responseOfCreateThread(withMessage message: ChatMessage) {
        /*
         *  -> check if we have saves the message uniqueId on the "map" property
         *      -> if yes: (means we send this request and waiting for the response of it)
         *          -> create the "CreateReturnData" variable
         *          -> check if Cache is enabled by the user
         *              -> if yes, save the income Data to the Cache
         *          -> call the "onResultCallback" which will send callback to createThread function (by using "createThreadCallbackToUser")
         *
         */
        log.verbose("Message of type 'CREATE_THREAD' recieved", context: "Chat")
        if Chat.map[message.uniqueId] != nil {
            let returnData: JSON = CreateReturnData(hasError:       false,
                                                    errorMessage:   "",
                                                    errorCode:      0,
                                                    result:         message.content?.convertToJSON(),
                                                    resultAsString: nil,
                                                    contentCount:   message.contentCount,
                                                    subjectId:      message.subjectId)
                .returnJSON()
            
            let callback: CallbackProtocol = Chat.map[message.uniqueId]!
            callback.onResultCallback(uID: message.uniqueId, response: returnData, success: { (successJSON) in
                self.createThreadCallbackToUser?(successJSON)
            }) { _ in }
            Chat.map.removeValue(forKey: message.uniqueId)
        }
        
    }
    
    public class CreateThreadCallback: CallbackProtocol {
        var mySendMessageParams: SendChatMessageVO
        init(parameters: SendChatMessageVO) {
            self.mySendMessageParams = parameters
        }
        func onResultCallback(uID:      String,
                              response: JSON,
                              success:  @escaping callbackTypeAlias,
                              failure:  @escaping callbackTypeAlias) {
            /*
             *  -> check if response hasError or not
             *      -> if no, create the "CreateThreadModel"
             *      -> send the "CreateThreadModel" as a callback
             *
             */
            log.verbose("CreateThreadCallback", context: "Chat")
            if (!response["hasError"].boolValue) {
                let resultData: JSON = response["result"]
                let createThreadModel = CreateThreadModel(messageContent:   resultData,
                                                          hasError:         response["hasError"].boolValue,
                                                          errorMessage:     response["errorMessage"].stringValue,
                                                          errorCode:        response["errorCode"].intValue)
                success(createThreadModel)
                
            }
        }
        
    }
    
}
