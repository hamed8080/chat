//
//  GetMessageDeliverList.swift
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
    
    func responseOfMessageDeliveryList(withMessage message: ChatMessage) {
        /*
         *
         *
         *
         */
        log.verbose("Message of type 'GET_MESSAGE_DELEVERY_PARTICIPANTS' recieved", context: "Chat")
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
            callback.onResultCallback(uID: message.uniqueId, response: returnData, success: { (successJSON) in
                self.getMessageDeliverListCallbackToUser?(successJSON)
            }) { _ in }
            Chat.map.removeValue(forKey: message.uniqueId)
        }
        
    }
    
    
    public class GetMessageDeliverList: CallbackProtocol {
        
        var sendParams: SendChatMessageVO
        init(parameters: SendChatMessageVO) {
            self.sendParams = parameters
        }
        
        func onResultCallback(uID: String, response: JSON, success: @escaping callbackTypeAlias, failure: @escaping callbackTypeAlias) {
            
            if (!response["hasError"].boolValue) {
                let content = sendParams.content?.convertToJSON()
                
                let getBlockedModel = GetThreadParticipantsModel(messageContent: response["result"].arrayValue,
                                                                 contentCount:  response["contentCount"].intValue,
                                                                 count:         content?["count"].intValue ?? 0,
                                                                 offset:        content?["offset"].intValue ?? 0,
                                                                 hasError:      response["hasError"].boolValue,
                                                                 errorMessage:  response["errorMessage"].stringValue,
                                                                 errorCode:     response["errorCode"].intValue)
                success(getBlockedModel)
            }
        }
        
    }
    
}
