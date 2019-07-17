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
    
    func responseOfRemoveParticipant(withMessage message: ChatMessage) {
        /*
         *
         *
         *
         */
        log.verbose("Message of type 'REMOVE_PARTICIPANT' recieved", context: "Chat")
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
                self.removeParticipantsCallbackToUser?(successJSON)
            }) { _ in }
            Chat.map.removeValue(forKey: message.uniqueId)
        }
        //            let threadIds = threadId
        //            let paramsToSend: JSON = ["threadIds": message.subjectId ?? 0]
        //            getThreads(params: paramsToSend, uniqueId: { _ in }) { (myResponse) in
        //                let myResponseModel: GetThreadsModel = myResponse as! GetThreadsModel
        //                let myResponseJSON: JSON = myResponseModel.returnDataAsJSON()
        //                let threads = myResponseJSON["result"]["threads"].arrayValue
        //
        //                let result: JSON = ["thread": threads[0]]
        ////                self.delegate?.threadEvents(type: ThreadEventTypes.removeParticipant, result: result)
        ////                self.delegate?.threadEvents(type: ThreadEventTypes.lastActivityTime, result: result)
        //            }
        
    }
    
    // ToDo: put the update cache to the upward function
    public class RemoveParticipantsCallback: CallbackProtocol {
        
        var sendParams: SendChatMessageVO
        init(parameters: SendChatMessageVO) {
            self.sendParams = parameters
        }
        
        func onResultCallback(uID: String,
                              response: JSON,
                              success: @escaping callbackTypeAlias,
                              failure: @escaping callbackTypeAlias) {
            /*
             *
             *
             *
             */
            log.verbose("RemoveParticipantsCallback", context: "Chat")
            
            if (!response["hasError"].boolValue) {
                
                var removeParticipantsArray = [Participant]()
                for item in response["result"].arrayValue {
                    let myParticipant = Participant(messageContent: item, threadId: sendParams.subjectId)
//                    Chat.cacheDB.deleteParticipant(inThread: sendParams["subjectId"].intValue, withParticipantIds: [myParticipant.id!])
                    
                    removeParticipantsArray.append(myParticipant)
                }
                
                let removeParticipantModel = RemoveParticipantModel(messageObjects: removeParticipantsArray,
                                                                    hasError: response["hasError"].boolValue,
                                                                    errorMessage: response["errorMessage"].stringValue,
                                                                    errorCode: response["errorCode"].intValue)
                success(removeParticipantModel)
            }
        }
    }
    
}
