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
    
    func chatDelegateAddParticipants(addParticipant: JSON) {
        let hasError = addParticipant["hasError"].boolValue
        let errorMessage = addParticipant["errorMessage"].stringValue
        let errorCode = addParticipant["errorCode"].intValue
        
        if (!hasError) {
            let messageContent = addParticipant["result"]
            
            //            var participants = [Participant]()
            //            for item in messageContent["participants"].arrayValue {
            //                let myParticipant = Participant(messageContent: item, threadId: messageContent["id"].intValue)
            //                participants.append(myParticipant)
            //            }
            //            Chat.cacheDB.saveThreadParticipantObjects(whereThreadIdIs: sendParams["subjectId"].intValue, withParticipants: participants)
            
            let addParticipantModel = AddParticipantModel(messageContent: messageContent, hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
            
//            delegate?.threadEvents(type: ThreadEventTypes.addParticipant, result: addParticipantModel)
        }
    }
    
    public class AddParticipantsCallback: CallbackProtocol {
        var sendParams: SendChatMessageVO
        init(parameters: SendChatMessageVO) {
            self.sendParams = parameters
        }
        func onResultCallback(uID: String, response: JSON, success: @escaping callbackTypeAlias, failure: @escaping callbackTypeAlias) {
            log.verbose("AddParticipantsCallback", context: "Chat")
            /*
             * + AddParticipantsRequest   {object}
             *    - subjectId             {long}
             *    + content               {list} List of CONTACT IDs
             *       -id                  {long}
             *    - uniqueId              {string}
             */
            
            let hasError = response["hasError"].boolValue
            let errorMessage = response["errorMessage"].stringValue
            let errorCode = response["errorCode"].intValue
            
            if (!hasError) {
                let messageContent = response["result"]
                
                var participants = [Participant]()
                for item in messageContent["participants"].arrayValue {
                    let myParticipant = Participant(messageContent: item, threadId: messageContent["id"].intValue)
                    participants.append(myParticipant)
                }
                Chat.cacheDB.saveThreadParticipantObjects(whereThreadIdIs: sendParams.subjectId!, withParticipants: participants)
                
                let addParticipantModel = AddParticipantModel(messageContent: messageContent, hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
                success(addParticipantModel)
            }
        }
    }
    
}
