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
        
        let returnData = CreateReturnData(hasError:         false,
                                          errorMessage:     "",
                                          errorCode:        0,
                                          result:           message.content?.convertToJSON() ?? [:],
                                          resultAsArray:    nil,
                                          resultAsString:   nil,
                                          contentCount:     message.contentCount,
                                          subjectId:        message.subjectId)
        
        if enableCache {
            var participantIds = [Int]()
            if let res = message.content?.convertToJSON() {
                let conversation = Conversation(messageContent: res)
                for participant in conversation.participants ?? [] {
                    let myParticipant = Participant(messageContent: participant.formatToJSON(), threadId: message.subjectId)
                    participantIds.append(myParticipant.id!)
                }
                Chat.cacheDB.deleteParticipant(inThread: message.subjectId!, withParticipantIds: participantIds)
            }
        }
        
        if Chat.map[message.uniqueId] != nil {
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
        
        func onResultCallback(uID:      String,
                              response: CreateReturnData,
                              success:  @escaping callbackTypeAlias,
                              failure:  @escaping callbackTypeAlias) {
            /*
             *
             *
             *
             */
            log.verbose("RemoveParticipantsCallback", context: "Chat")
            
            if let arrayContent = response.resultAsArray {
                
                var removeParticipantsArray = [Participant]()
                for item in arrayContent {
                    let myParticipant = Participant(messageContent: item, threadId: sendParams.subjectId)
//                    Chat.cacheDB.deleteParticipant(inThread: sendParams["subjectId"].intValue, withParticipantIds: [myParticipant.id!])
                    removeParticipantsArray.append(myParticipant)
                }
                
                let removeParticipantModel = RemoveParticipantModel(messageObjects: removeParticipantsArray,
                                                                    hasError:       response.hasError,
                                                                    errorMessage:   response.errorMessage,
                                                                    errorCode:      response.errorCode)
                success(removeParticipantModel)
            }
        }
    }
    
}
