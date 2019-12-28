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
        /**
         *
         */
        log.verbose("Message of type 'THREAD_PARTICIPANTS' recieved", context: "Chat")
        
        let returnData = CreateReturnData(hasError:       false,
                                          errorMessage:   "",
                                          errorCode:      0,
                                          result:         nil,
                                          resultAsArray:  message.content?.convertToJSON().array,
                                          resultAsString: nil,
                                          contentCount:   message.contentCount,
                                          subjectId:      message.subjectId)
        
        if enableCache {
            let threadParticipantsModel = GetThreadParticipantsModel(messageContent: returnData.resultAsArray ?? [],
                                                                     contentCount: returnData.contentCount,
                                                                     count:        0,
                                                                     offset:       0,
                                                                     hasError:     false,
                                                                     errorMessage: "",
                                                                     errorCode:    0)
            let tParticipantsListChangeEM = ThreadEventModel(type:          ThreadEventTypes.THREAD_PARTICIPANTS_LIST_CHANGE,
                                                             participants:  threadParticipantsModel.participants,
                                                             threads:       nil,
                                                             threadId:      message.subjectId,
                                                             senderId:      nil)
            delegate?.threadEvents(model: tParticipantsListChangeEM)
            
            var participants = [Participant]()
            var adminRequest = false
            for item in message.content?.convertToJSON() ?? [] {
                let myParticipant = Participant(messageContent: item.1, threadId: message.subjectId!)
                if ((myParticipant.roles?.count ?? 0) > 0) {
                    adminRequest = true
                }
                participants.append(myParticipant)
            }
            Chat.cacheDB.saveThreadParticipantObjects(whereThreadIdIs: message.subjectId!, withParticipants: participants, isAdminRequest: adminRequest)
        }
        
        if Chat.map[message.uniqueId] != nil {
            let callback: CallbackProtocol = Chat.map[message.uniqueId]!
            callback.onResultCallback(uID:      message.uniqueId,
                                      response: returnData,
                                      success:  { (successJSON) in
                self.threadParticipantsCallbackToUser?(successJSON)
            }) { _ in }
            Chat.map.removeValue(forKey: message.uniqueId)
        }
    }
    
    
    public class GetThreadParticipantsCallbacks: CallbackProtocol {
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
            log.verbose("GetThreadParticipantsCallbacks", context: "Chat")
            
            if let arrayContent = response.resultAsArray {
                let content = sendParams.content?.convertToJSON()
                
//                if Chat.sharedInstance.enableCache {
//                    var participants = [Participant]()
//                    var adminRequest = false
//                    for item in response.resultAsArray ?? [] {
//                        let myParticipant = Participant(messageContent: item, threadId: response.subjectId!)
//                        if ((myParticipant.roles?.count ?? 0) > 0) {
//                            adminRequest = true
//                        }
//                        participants.append(myParticipant)
//                    }
//
//                    handleServerAndCacheDifferential(sendParams: sendParams, serverResponse: participants, adminRequest: adminRequest)
//                    Chat.cacheDB.saveThreadParticipantObjects(whereThreadIdIs: response.subjectId!, withParticipants: participants, isAdminRequest: adminRequest)
//                }
                
                let getThreadParticipantsModel = GetThreadParticipantsModel(messageContent: arrayContent,
                                                                            contentCount:   response.contentCount,
                                                                            count:          content?["count"].intValue ?? 0,
                                                                            offset:         content?["offset"].intValue ?? 0,
                                                                            hasError:       response.hasError,
                                                                            errorMessage:   response.errorMessage,
                                                                            errorCode:      response.errorCode)
                success(getThreadParticipantsModel)
            }
        }
        
        /*
        private func handleServerAndCacheDifferential(sendParams: SendChatMessageVO, serverResponse: [Participant], adminRequest: Bool) {
            
            if let content = sendParams.content?.convertToJSON() {
                let getThreadParticipantsInput = GetThreadParticipantsRequestModel(json: content)
                if let cacheParticipantsResult = Chat.cacheDB.retrieveThreadParticipants(admin:     adminRequest,
                                                                                         ascending: true,
                                                                                         count:     getThreadParticipantsInput.count ?? 50,
                                                                                         offset:    getThreadParticipantsInput.offset ?? 0,
                                                                                         threadId:  getThreadParticipantsInput.threadId,
                                                                                         timeStamp: Chat.sharedInstance.cacheTimeStamp) {
                    // check if there was any thread on the server response that wasn't on the cache, send them as New Thread Event to the client
                    for participant in serverResponse {
                        var foundThrd = false
                        for cacheParticipant in cacheParticipantsResult.participants {
                            if (participant.id == cacheParticipant.id) {
                                foundThrd = true
                                break
                            }
                        }
                        // meands this participant was not on the cache response
                        if !foundThrd {
                            let tNewParticipantEM = ThreadEventModel(type: ThreadEventTypes.THREAD_PARTICIPANT_NEW,
                                                                     participants: [participant],
                                                                     threads: nil,
                                                                     threadId: nil,
                                                                     senderId: nil)
                            Chat.sharedInstance.delegate?.threadEvents(model: tNewParticipantEM)
                        }
                    }
                    
                    // check if there was any thread on the cache response that wasn't on the server response, send them as Delete Thread Event to the client
                    for cacheParticipant in cacheParticipantsResult.participants {
                        var foundThrd = false
                        for participant in serverResponse {
                            if (cacheParticipant.id == participant.id) {
                                foundThrd = true
                                break
                            }
                        }
                        // meands this contact was not on the server response
                        if !foundThrd {
                            let tNewParticipantEM = ThreadEventModel(type: ThreadEventTypes.THREAD_PARTICIPANT_DELETE,
                                                                     participants: [cacheParticipant],
                                                                     threads: nil,
                                                                     threadId: nil,
                                                                     senderId: nil)
                            Chat.sharedInstance.delegate?.threadEvents(model: tNewParticipantEM)
                        }
                    }
                    
                }
            }
        }
        */
        
    }
    
}
