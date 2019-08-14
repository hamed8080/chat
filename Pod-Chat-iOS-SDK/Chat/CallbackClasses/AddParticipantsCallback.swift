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
        
        let returnData = CreateReturnData(hasError:         false,
                                          errorMessage:     "",
                                          errorCode:        0,
                                          result:           message.content?.convertToJSON() ?? [:],
                                          resultAsArray:    nil,
                                          resultAsString:   nil,
                                          contentCount:     message.contentCount,
                                          subjectId:        message.subjectId)
        
        if enableCache {
            var participants = [Participant]()
            if let res = message.content?.convertToJSON() {
                let conversation = Conversation(messageContent: res)
                for participant in conversation.participants ?? [] {
                    let myParticipant = Participant(messageContent: participant.formatToJSON(), threadId: message.subjectId)
                    participants.append(myParticipant)
                }
                Chat.cacheDB.saveThreadParticipantObjects(whereThreadIdIs: message.subjectId!, withParticipants: participants)
            }
        }
        
        if Chat.map[message.uniqueId] != nil {
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
        
        func onResultCallback(uID:      String,
                              response: CreateReturnData,
                              success:  @escaping callbackTypeAlias,
                              failure:  @escaping callbackTypeAlias) {
            /*
             *
             *
             *
             */
            log.verbose("AddParticipantsCallback", context: "Chat")
            
            if let content = response.result {
                
//                var participants = [Participant]()
//                for item in response["result"]["participants"].arrayValue {
//                    let myParticipant = Participant(messageContent: item, threadId: response["result"]["id"].intValue)
//                    participants.append(myParticipant)
//                }
//                Chat.cacheDB.saveThreadParticipantObjects(whereThreadIdIs: sendParams.subjectId!, withParticipants: participants)
                
                let addParticipantModel = AddParticipantModel(messageContent:   content,
                                                              hasError:         response.hasError,
                                                              errorMessage:     response.errorMessage,
                                                              errorCode:        response.errorCode)
                success(addParticipantModel)
            }
        }
    }
    
}
