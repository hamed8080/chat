//
//  CallManagementMethods.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 9/2/1399 AP.
//  Copyright © 1399 Mahyar Zhiani. All rights reserved.
//

import Foundation
import FanapPodAsyncSDK
import SwiftyJSON

// MARK: - Public Methods
// MARK: - Call Management

extension Chat {
    
    
    public func callRequest(inputModel callRequestInput:  SendCallRequest,
                            uniqueId:       @escaping (String) -> (),
                            completion:     @escaping callbackTypeAlias) {
        
        log.verbose("Try to request to Call with this parameters: \n \(callRequestInput)", context: "Chat")
        uniqueId(callRequestInput.uniqueId)
        
        callRequestCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  ChatMessageVOTypes.CALL_REQUEST.intValue(),
                                            content:            String(describing: callRequestInput.convertContentToJSON),
                                            messageType:        nil,
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          nil,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           callRequestInput.typeCode ?? generalTypeCode,
                                            uniqueId:           callRequestInput.uniqueId,
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: nil)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  nil)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callbacks:          [(CallRequestCallback(), callRequestInput.uniqueId)],
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil)
    }
    
    
    
    public func callAcceptRequest(inputModel callAcceptInput:   AcceptCallRequest,
                                  uniqueId:     @escaping (String) -> (),
                                  completion:   @escaping callbackTypeAlias) {
        
        log.verbose("Try to request to AcceptCall with this parameters: \n \(callAcceptInput.convertContentToJSON())", context: "Chat")
        uniqueId(callAcceptInput.uniqueId)
        
        callAcceptCallbackToUser = completion
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  ChatMessageVOTypes.ACCEPT_CALL.intValue(),
                                            content:            String(describing: callAcceptInput.convertContentToJSON),
                                            messageType:        nil,
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          nil,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           callAcceptInput.typeCode ?? generalTypeCode,
                                            uniqueId:           callAcceptInput.uniqueId,
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: nil)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  nil)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callbacks:          [(CallAcceptedCallback(), callAcceptInput.uniqueId)],
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil)
    }
    
    
    
    public func callRejectRequest(inputModel callRejectInput:   RejectCallRequest) {
        
        log.verbose("Try to request to RejectCall with this parameters: \n \(callRejectInput.convertContentToJSON())", context: "Chat")
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  ChatMessageVOTypes.REJECT_CALL.intValue(),
                                            content:            String(describing: callRejectInput.convertContentToJSON),
                                            messageType:        nil,
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          nil,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           callRejectInput.typeCode ?? generalTypeCode,
                                            uniqueId:           callRejectInput.uniqueId,
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: nil)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  nil)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callbacks:          nil,
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil)
    }
    
}
