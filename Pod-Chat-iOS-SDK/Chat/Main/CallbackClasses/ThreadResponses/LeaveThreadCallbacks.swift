//
//  LeaveThreadCallbacks.swift
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
    
    /// LeaveThread Response comes from server
    ///
    /// - Outputs:
    ///    - it doesn't have direct output,
    ///    - but on the situation where the response is valid,
    ///    - it will call the "onResultCallback" callback to leaveThread function (by using "leaveThreadCallbackToUser")
    @available(*,deprecated , message:"Removed in XX.XX.XX version")
    func responseOfLeaveThread(withMessage message: ChatMessage) {
        log.verbose("Message of type 'LEAVE_THREAD' recieved", context: "Chat")
        
        let returnData = CreateReturnData(hasError:         false,
                                          errorMessage:     "",
                                          errorCode:        0,
                                          result:           message.content?.convertToJSON() ?? [:],
                                          resultAsArray:    nil,
                                          resultAsString:   nil,
                                          contentCount:     message.contentCount,
                                          subjectId:        message.subjectId)
        
        let leaveThreadModel = ThreadResponse(messageContent:   message.content?.convertToJSON() ?? [:],
                                              hasError:         false,
                                              errorMessage:     "",
                                              errorCode:        0)
        
        let tLeaveEM = ThreadEventModel(type:           ThreadEventTypes.THREAD_LEAVE_PARTICIPANT,
                                        participants:   leaveThreadModel.thread?.participants,
                                        threads:        nil,
                                        threadId:       message.subjectId,
                                        senderId:       nil,
                                        unreadCount:    message.content?.convertToJSON()["unreadCount"].int,
                                        pinMessage:     nil)
        delegate?.threadEvents(model: tLeaveEM)
        let tLastActivityEM = ThreadEventModel(type:            ThreadEventTypes.THREAD_LAST_ACTIVITY_TIME,
                                               participants:    nil,
                                               threads:         nil,
                                               threadId:        message.subjectId,
                                               senderId:        nil,
                                               unreadCount:     message.content?.convertToJSON()["unreadCount"].int,
                                               pinMessage:      nil)
        delegate?.threadEvents(model: tLastActivityEM)
        
        
        if enableCache {
            if let threadJSON = message.content?.convertToJSON() {
                let conversation = Conversation(messageContent: threadJSON)
                if let _ = conversation.title {
                    var participantIds = [Int]()
                    for participant in conversation.participants ?? [] {
                        let myParticipant = Participant(messageContent: participant.formatToJSON(), threadId: message.subjectId)
                        participantIds.append(myParticipant.id!)
                    }
                    Chat.cacheDB.deleteParticipant(inThread: message.subjectId!, withParticipantIds: participantIds)
                } else {
                    Chat.cacheDB.deleteThreads(withThreadIds: [conversation.id!])
                }
            }
        }
        
        if Chat.map[message.uniqueId] != nil {
            let callback: CallbackProtocol = Chat.map[message.uniqueId]!
            callback.onResultCallback(uID:      message.uniqueId,
                                      response: returnData,
                                      success:  { (successJSON) in
                self.leaveThreadCallbackToUser?(successJSON)
            }) { _ in }
            Chat.map.removeValue(forKey: message.uniqueId)
            
        } else if (Chat.spamMap[message.uniqueId] != nil) {
            let callback: CallbackProtocol = Chat.spamMap[message.uniqueId]!.first!
            callback.onResultCallback(uID:      message.uniqueId,
                                      response: returnData,
                                      success:  { (successJSON) in
                                        self.spamPvThreadCallbackToUser?(successJSON)
            }) { _ in }
            Chat.spamMap[message.uniqueId]?.removeFirst()
            if (Chat.spamMap[message.uniqueId]!.count < 1) {
                Chat.spamMap.removeValue(forKey: message.uniqueId)
            }
        }
        
    }
    
    @available(*,deprecated , message:"Removed in XX.XX.XX version")
    public class LeaveThreadCallbacks: CallbackProtocol {
        func onResultCallback(uID:      String,
                              response: CreateReturnData,
                              success:  @escaping callbackTypeAlias,
                              failure:  @escaping callbackTypeAlias) {
            log.verbose("LeaveThreadCallbacks", context: "Chat")
            
            if let content = response.result {
                let leaveThreadModel = ThreadResponse(messageContent:   content,
                                                      hasError:         response.hasError,
                                                      errorMessage:     response.errorMessage,
                                                      errorCode:        response.errorCode)
                success(leaveThreadModel)
            }
        }
    }
    
}
