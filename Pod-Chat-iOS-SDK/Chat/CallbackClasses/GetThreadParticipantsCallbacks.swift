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
    
    func responseOfThreadParticipants(withMessage message: ChatMessage) {
        /*
         *
         *
         *
         */
        log.verbose("Message of type 'THREAD_PARTICIPANTS' recieved", context: "Chat")
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
                self.threadParticipantsCallbackToUser?(successJSON)
            }) { _ in }
            Chat.map.removeValue(forKey: message.uniqueId)
        }
    }
    
    // ToDo: put the update cache to the upward function
    public class GetThreadParticipantsCallbacks: CallbackProtocol {
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
            log.verbose("GetThreadParticipantsCallbacks", context: "Chat")
            
            if (!response["hasError"].boolValue) {
                let content = sendParams.content?.convertToJSON()
                
                var participants = [Participant]()
                for item in response["result"].arrayValue {
                    let myParticipant = Participant(messageContent: item, threadId: sendParams.subjectId!)
                    participants.append(myParticipant)
                }
                Chat.cacheDB.saveThreadParticipantObjects(whereThreadIdIs: sendParams.subjectId!, withParticipants: participants)
                
                let getThreadParticipantsModel = GetThreadParticipantsModel(messageContent: response["result"].arrayValue,
                                                                            contentCount:   response["contentCount"].intValue,
                                                                            count:          content?["count"].intValue ?? 0,
                                                                            offset:         content?["offset"].intValue ?? 0,
                                                                            hasError:       response["hasError"].boolValue,
                                                                            errorMessage:   response["errorMessage"].stringValue,
                                                                            errorCode:      response["errorCode"].intValue)
                success(getThreadParticipantsModel)
            }
        }
    }
    
}
