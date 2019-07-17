//
//  AddParticipantsCallback.swift
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
    
    func responseOfAddParticipant(withMessage message: ChatMessage) {
        /*
         *
         *
         *
         */
        log.verbose("Message of type 'ADD_PARTICIPANT' recieved", context: "Chat")
        if Chat.map[message.uniqueId] != nil {
            let returnData: JSON = CreateReturnData(hasError:       false,
                                                    errorMessage:   "",
                                                    errorCode:      0,
                                                    result:         message.content?.convertToJSON() ?? [:],
                                                    resultAsString: nil,
                                                    contentCount:   message.contentCount,
                                                    subjectId:      message.subjectId)
                .returnJSON()
            
            if enableCache {
                
            }
            
            let callback: CallbackProtocol = Chat.map[message.uniqueId]!
            callback.onResultCallback(uID: message.uniqueId, response: returnData, success: { (successJSON) in
                self.addParticipantsCallbackToUser?(successJSON)
            }) { _ in }
            Chat.map.removeValue(forKey: message.uniqueId)
        }
        
        // this functionality has beed deprecated
        /*
         let threadIds = messageContent["id"].intValue
         let paramsToSend: JSON = ["threadIds": threadIds]
         getThreads(params: paramsToSend, uniqueId: { _ in }) { (response) in
         let responseModel: GetThreadsModel = response as! GetThreadsModel
         let responseJSON: JSON = responseModel.returnDataAsJSON()
         let threads = responseJSON["result"]["threads"].arrayValue
         
         let result: JSON = ["thread": threads[0]]
         self.delegate?.threadEvents(type: "THREAD_ADD_PARTICIPANTS", result: result)
         self.delegate?.threadEvents(type: "THREAD_LAST_ACTIVITY_TIME", result: result)
         }
         */
    }
    
    // ToDo: put the update cache to the upward function
    public class AddParticipantsCallback: CallbackProtocol {
        
        var sendParams: SendChatMessageVO
        init(parameters: SendChatMessageVO) {
            self.sendParams = parameters
        }
        
        func onResultCallback(uID: String, response: JSON, success: @escaping callbackTypeAlias, failure: @escaping callbackTypeAlias) {
            /*
             *
             *
             *
             */
            log.verbose("AddParticipantsCallback", context: "Chat")
            
            if (!response["hasError"].boolValue) {
                
                var participants = [Participant]()
                for item in response["result"]["participants"].arrayValue {
                    let myParticipant = Participant(messageContent: item, threadId: response["result"]["id"].intValue)
                    participants.append(myParticipant)
                }
                Chat.cacheDB.saveThreadParticipantObjects(whereThreadIdIs: sendParams.subjectId!, withParticipants: participants)
                
                let addParticipantModel = AddParticipantModel(messageContent:   response["result"],
                                                              hasError:         response["hasError"].boolValue,
                                                              errorMessage:     response["errorMessage"].stringValue,
                                                              errorCode:        response["errorCode"].intValue)
                success(addParticipantModel)
            }
        }
    }
    
}
