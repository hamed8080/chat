//
//  GetThreadParticipantsCallbacks.swift
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
    
    func chatDelegateGetParticipants(getParticipants: JSON) {
        let hasError = getParticipants["hasError"].boolValue
        let errorMessage = getParticipants["errorMessage"].stringValue
        let errorCode = getParticipants["errorCode"].intValue
        
        if (!hasError) {
            let result = getParticipants["result"]
            let count = result["contentCount"].intValue
            let offset = result["nextOffset"].intValue
            
            let messageContent: [JSON] = getParticipants["result"].arrayValue
            let contentCount = getParticipants["contentCount"].intValue
            
            //            var participants = [Participant]()
            //            for item in messageContent {
            //                let myParticipant = Participant(messageContent: item, threadId: sendParams["subjectId"].intValue)
            //                participants.append(myParticipant)
            //            }
            //            Chat.cacheDB.saveThreadParticipantObjects(whereThreadIdIs: sendParams["subjectId"].intValue, withParticipants: participants)
            
            let getThreadParticipantsModel = GetThreadParticipantsModel(messageContent: messageContent, contentCount: contentCount, count: count, offset: offset - count, hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
            
//            delegate?.threadEvents(type: ThreadEventTypes.getThreadParticipants, result: getThreadParticipantsModel)
        }
    }
    
    public class GetThreadParticipantsCallbacks: CallbackProtocol {
        var sendParams: SendChatMessageVO
        init(parameters: SendChatMessageVO) {
            self.sendParams = parameters
        }
        func onResultCallback(uID: String, response: JSON, success: @escaping callbackTypeAlias, failure: @escaping callbackTypeAlias) {
            log.verbose("GetThreadParticipantsCallbacks", context: "Chat")
            
            let hasError = response["hasError"].boolValue
            let errorMessage = response["errorMessage"].stringValue
            let errorCode = response["errorCode"].intValue
            
            if (!hasError) {
//                let content = sendParams["content"]
                let content = sendParams.content.convertToJSON()
                let count = content["count"].intValue
                let offset = content["offset"].intValue
                
                let messageContent: [JSON] = response["result"].arrayValue
                let contentCount = response["contentCount"].intValue
                
                
                // save data comes from server to the Cache, in the Back Thread
                //                DispatchQueue.global().async {
                
                var participants = [Participant]()
                for item in messageContent {
                    let myParticipant = Participant(messageContent: item, threadId: sendParams.subjectId!)
                    participants.append(myParticipant)
                }
                Chat.cacheDB.saveThreadParticipantObjects(whereThreadIdIs: sendParams.subjectId!, withParticipants: participants)
                //                }
                
                let getThreadParticipantsModel = GetThreadParticipantsModel(messageContent: messageContent, contentCount: contentCount, count: count, offset: offset, hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
                
                success(getThreadParticipantsModel)
            }
        }
    }
    
}
