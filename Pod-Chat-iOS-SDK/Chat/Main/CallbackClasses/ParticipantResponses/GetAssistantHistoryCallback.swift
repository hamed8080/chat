//
//  GetAssistantHistoryCallback.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 12/9/1399 AP.
//  Copyright © 1399 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON
import SwiftyBeaver
import FanapPodAsyncSDK

extension Chat {
    
    func responseOfGetAssistantHistory(withMessage message: ChatMessage) {
        log.verbose("Message of type 'GET_ASSISTANT_HISTORY' recieved", context: "Chat")
        
        let returnData = CreateReturnData(hasError:         false,
                                          errorMessage:     "",
                                          errorCode:        0,
                                          result:           nil,
                                          resultAsArray:    message.content?.convertToJSON().array,
                                          resultAsString:   nil,
                                          contentCount:     nil,
                                          subjectId:        message.subjectId)
        
        
        if Chat.map[message.uniqueId] != nil {
            let callback: CallbackProtocol = Chat.map[message.uniqueId]!
            callback.onResultCallback(uID: message.uniqueId, response: returnData, success: { (successJSON) in
                self.getAssistantsHistoryCallbackToUser?(successJSON)
            }) { _ in }
            Chat.map.removeValue(forKey: message.uniqueId)
        }
    }
    
    
    
    public class GetAssistantHistoryCallback: CallbackProtocol {
        
        func onResultCallback(uID:      String,
                              response: CreateReturnData,
                              success:  @escaping callbackTypeAlias,
                              failure:  @escaping callbackTypeAlias) {
            log.verbose("AssistantHistoryCallback", context: "Chat")
            
            if let content = response.resultAsArray as? [JSON] {
                let addParticipantModel = AssistantActionsResponse(messageContent:  content,
                                                                   hasError:        response.hasError,
                                                                   errorMessage:    response.errorMessage,
                                                                   errorCode:       response.errorCode)
                success(addParticipantModel)
            }
        }
    }
    
    
}


