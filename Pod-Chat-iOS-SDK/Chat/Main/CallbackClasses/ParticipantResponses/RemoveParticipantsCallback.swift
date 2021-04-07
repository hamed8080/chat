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
    
    /// RemoveParticipant Response comes from server
    ///
    /// - Outputs:
    ///    - it doesn't have direct output,
    ///    - but on the situation where the response is valid,
    ///    - it will call the "onResultCallback" callback to removeParticipant function (by using "removeParticipantsCallbackToUser")
    @available(*,deprecated , message:"Removed in XX.XX.XX version")
    func responseOfRemoveParticipant(withMessage message: ChatMessage) {
        log.verbose("Message of type 'REMOVE_PARTICIPANT' recieved", context: "Chat")
        
        let returnData = CreateReturnData(hasError:         false,
                                          errorMessage:     "",
                                          errorCode:        0,
                                          result:           nil,
                                          resultAsArray:    message.content?.convertToJSON().array,
                                          resultAsString:   nil,
                                          contentCount:     message.contentCount,
                                          subjectId:        message.subjectId)
        
        let tRemoveParticipantEM = ThreadEventModel(type:           ThreadEventTypes.THREAD_REMOVE_PARTICIPANTS,
                                                    participants:   nil,
                                                    threads:        nil,
                                                    threadId:       message.subjectId,
                                                    senderId:       nil,
                                                    unreadCount:    message.content?.convertToJSON()["unreadCount"].int,
                                                    pinMessage:     nil)
        delegate?.threadEvents(model: tRemoveParticipantEM)
        let tLastActivityEM = ThreadEventModel(type:            ThreadEventTypes.THREAD_LAST_ACTIVITY_TIME,
                                               participants:    nil,
                                               threads:         nil,
                                               threadId:        message.subjectId,
                                               senderId:        nil,
                                               unreadCount:     message.content?.convertToJSON()["unreadCount"].int,
                                               pinMessage:      nil)
        delegate?.threadEvents(model: tLastActivityEM)
        
        
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
        
    }
    
    @available(*,deprecated , message:"Removed in XX.XX.XX version")
    public class RemoveParticipantsCallback: CallbackProtocol {
        var sendParams: SendChatMessageVO
        init(parameters: SendChatMessageVO) {
            self.sendParams = parameters
        }
        
        func onResultCallback(uID:      String,
                              response: CreateReturnData,
                              success:  @escaping callbackTypeAlias,
                              failure:  @escaping callbackTypeAlias) {
            log.verbose("RemoveParticipantsCallback", context: "Chat")
            
            if let arrayContent = response.resultAsArray as? [JSON] {
                
                var removeParticipantsArray = [Participant]()
                for item in arrayContent {
                    let myParticipant = Participant(messageContent: item, threadId: sendParams.subjectId)
                    removeParticipantsArray.append(myParticipant)
                }
                
                let removeParticipantModel = RemoveParticipantResponse(messageObjects:  removeParticipantsArray,
                                                                       hasError:        response.hasError,
                                                                       errorMessage:    response.errorMessage,
                                                                       errorCode:       response.errorCode)
                success(removeParticipantModel)
            }
        }
    }
    
}
