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
        
        let returnData = CreateReturnData(hasError:         false,
                                          errorMessage:     "",
                                          errorCode:        0,
                                          result:           nil,
                                          resultAsArray:    message.content?.convertToJSON().array,
                                          resultAsString:   nil,
                                          contentCount:     message.contentCount,
                                          subjectId:        message.subjectId)
        
        if Chat.map[message.uniqueId] != nil {
            let callback: CallbackProtocol = Chat.map[message.uniqueId]!
            callback.onResultCallback(uID:      message.uniqueId,
                                      response: returnData,
                                      success:  { (successJSON) in
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
        
        func onResultCallback(uID:      String,
                              response: CreateReturnData,
                              success:  @escaping callbackTypeAlias,
                              failure:  @escaping callbackTypeAlias) {
            
            if let arrayContent = response.resultAsArray {
                let content = sendParams.content?.convertToJSON()
                
                let getBlockedModel = GetThreadParticipantsModel(messageContent: arrayContent,
                                                                 contentCount:  response.contentCount,
                                                                 count:         content?["count"].intValue ?? 0,
                                                                 offset:        content?["offset"].intValue ?? 0,
                                                                 hasError:      response.hasError,
                                                                 errorMessage:  response.errorMessage,
                                                                 errorCode:     response.errorCode)
                success(getBlockedModel)
            }
        }
        
    }
    
}
