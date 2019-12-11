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
        /**
         *
         */
        log.verbose("Message of type 'ADD_PARTICIPANT' recieved", context: "Chat")
        
        if let threadId = message.subjectId {
            delegate?.threadEvents(type: ThreadEventTypes.THREAD_LAST_ACTIVITY_TIME, result: threadId)
            if let conAsJSON = message.content?.convertToJSON() {
                let conversation = Conversation(messageContent: conAsJSON)
                delegate?.threadEvents(type: ThreadEventTypes.THREAD_ADD_PARTICIPANTS, result: conversation)
            }
        }
        
        if enableCache {
            var participants = [Participant]()
            if let res = message.content?.convertToJSON() {
                let conversation = Conversation(messageContent: res)
                for participant in conversation.participants ?? [] {
                    let myParticipant = Participant(messageContent: participant.formatToJSON(), threadId: message.subjectId)
                    participants.append(myParticipant)
                }
                Chat.cacheDB.saveThreadParticipantObjects(whereThreadIdIs: message.subjectId!, withParticipants: participants, isAdminRequest: false)
            }
        }
        
        let returnData = CreateReturnData(hasError:         false,
                                          errorMessage:     "",
                                          errorCode:        0,
                                          result:           message.content?.convertToJSON() ?? [:],
                                          resultAsArray:    nil,
                                          resultAsString:   nil,
                                          contentCount:     message.contentCount,
                                          subjectId:        message.subjectId)
        
        if Chat.map[message.uniqueId] != nil {
            let callback: CallbackProtocol = Chat.map[message.uniqueId]!
            callback.onResultCallback(uID: message.uniqueId, response: returnData, success: { (successJSON) in
                self.addParticipantsCallbackToUser?(successJSON)
            }) { _ in }
            Chat.map.removeValue(forKey: message.uniqueId)
        }
        
    }
    
    
    public class AddParticipantsCallback: CallbackProtocol {
        
        var sendParams: SendChatMessageVO
        init(parameters: SendChatMessageVO) {
            self.sendParams = parameters
        }
        
        func onResultCallback(uID:      String,
                              response: CreateReturnData,
                              success:  @escaping callbackTypeAlias,
                              failure:  @escaping callbackTypeAlias) {
            /**
             *
             */
            log.verbose("AddParticipantsCallback", context: "Chat")
            
            if let content = response.result {
                let addParticipantModel = AddParticipantModel(messageContent:   content,
                                                              hasError:         response.hasError,
                                                              errorMessage:     response.errorMessage,
                                                              errorCode:        response.errorCode)
                success(addParticipantModel)
            }
        }
    }
    
}
