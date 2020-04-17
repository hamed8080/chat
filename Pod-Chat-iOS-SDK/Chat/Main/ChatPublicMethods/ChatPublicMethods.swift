//
//  ChatPublicMethods.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 3/18/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import FanapPodAsyncSDK
import SwiftyJSON
import Alamofire


// MARK: - Public Methods

extension Chat {
    
    public func isConnectedToInternet() -> Bool {
        return NetworkReachabilityManager()!.isReachable
    }
    
    
    /// Deliver:
    /// send deliver for some message.
    ///
    /// By calling this function, a request of type 4 (DELIVERY) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "DeliverSeenRequestModel" to this function
    ///
    /// Outputs:
    /// - this method does not have any output
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (DeliverSeenRequestModel)
    public func deliver(inputModel deliverInput: DeliverSeenRequestModel) {
        
        log.verbose("Try to send deliver message for a message id with this parameters: \n messageId = \(deliverInput.messageId) , ownerId = \(deliverInput.ownerId)", context: "Chat")
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  ChatMessageVOTypes.DELIVERY.intValue(),
                                            content:            "\(deliverInput.messageId)",
                                            messageType:        nil,
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          nil,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           deliverInput.typeCode ?? generalTypeCode,
                                            uniqueId:           nil,
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: nil)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  3)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callbacks:          nil,
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil)
    }
    
    
    /// Seen:
    /// send seen for some message.
    ///
    /// By calling this function, a request of type 5 (SEEN) will send throut Chat-SDK,
    /// then the response will come back as callbacks to client whose calls this function.
    ///
    /// Inputs:
    /// - you have to send your parameters as "DeliverSeenRequestModel" to this function
    ///
    /// Outputs:
    /// - this method does not have any output
    ///
    /// - parameter inputModel: (input) you have to send your parameters insid this model. (DeliverSeenRequestModel)
    public func seen(inputModel seenInput: DeliverSeenRequestModel) {
        
        log.verbose("Try to send seen message for a message id with this parameters: \n messageId = \(seenInput.messageId) , ownerId = \(seenInput.ownerId)", context: "Chat")
        
        let chatMessage = SendChatMessageVO(chatMessageVOType:  ChatMessageVOTypes.SEEN.intValue(),
                                            content:            "\(seenInput.messageId)",
                                            messageType:        nil,
                                            metadata:           nil,
                                            repliedTo:          nil,
                                            systemMetadata:     nil,
                                            subjectId:          nil,
                                            token:              token,
                                            tokenIssuer:        nil,
                                            typeCode:           seenInput.typeCode ?? generalTypeCode,
                                            uniqueId:           nil,
                                            uniqueIds:          nil,
                                            isCreateThreadAndSendMessage: nil)
        
        let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                              msgTTL:       msgTTL,
                                              peerName:     serverName,
                                              priority:     msgPriority,
                                              pushMsgType:  3)
        
        sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                callbacks:          nil,
                                sentCallback:       nil,
                                deliverCallback:    nil,
                                seenCallback:       nil)
    }
    
}
