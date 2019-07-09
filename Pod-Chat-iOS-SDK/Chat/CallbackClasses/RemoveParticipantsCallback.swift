//
//  RemoveParticipantsCallback.swift
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
    
    func chatDelegateRemoveParticipants(removeParticipants: JSON) {
        let hasError = removeParticipants["hasError"].boolValue
        let errorMessage = removeParticipants["errorMessage"].stringValue
        let errorCode = removeParticipants["errorCode"].intValue
        
        if (!hasError) {
            
            let removeParticipantResult = removeParticipants["result"].arrayValue
            
            var removeParticipantsArray = [Participant]()
            for item in removeParticipantResult {
                let myParticipant = Participant(messageContent: item, threadId: item["thread"]["id"].int)
                Chat.cacheDB.deleteParticipant(inThread: item["thread"]["id"].intValue, withParticipantIds: [myParticipant.id!])
                
                removeParticipantsArray.append(myParticipant)
            }
            
            let removeParticipantModel = RemoveParticipantModel(messageObjects: removeParticipantsArray, hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
            
//            delegate?.threadEvents(type: ThreadEventTypes.removeParticipant, result: removeParticipantModel)
        }
    }
    
    public class RemoveParticipantsCallback: CallbackProtocol {
        var sendParams: JSON
        init(parameters: JSON) {
            self.sendParams = parameters
        }
        func onResultCallback(uID: String, response: JSON, success: @escaping callbackTypeAlias, failure: @escaping callbackTypeAlias) {
            log.verbose("RemoveParticipantsCallback", context: "Chat")
            /*
             * + RemoveParticipantsRequest    {object}
             *    - subjectId                 {long}
             *    + content                   {list} List of PARTICIPANT IDs from Thread's Participants object
             *       -id                      {long}
             *    - uniqueId                  {string}
             */
            
            let hasError = response["hasError"].boolValue
            let errorMessage = response["errorMessage"].stringValue
            let errorCode = response["errorCode"].intValue
            
            if (!hasError) {
                
                let removeParticipantResult = response["result"].arrayValue
                
                var removeParticipantsArray = [Participant]()
                for item in removeParticipantResult {
                    let myParticipant = Participant(messageContent: item, threadId: sendParams["subjectId"].int)
                    //                    Chat.cacheDB.deleteParticipant(inThread: sendParams["subjectId"].intValue, withParticipantIds: [myParticipant.id!])
                    
                    removeParticipantsArray.append(myParticipant)
                }
                
                let removeParticipantModel = RemoveParticipantModel(messageObjects: removeParticipantsArray, hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
                success(removeParticipantModel)
            }
        }
    }
    
}
