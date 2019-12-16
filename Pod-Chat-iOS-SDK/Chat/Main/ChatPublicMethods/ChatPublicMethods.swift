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


// MARK: - Public Methods

extension Chat {
    
    
    
    public func deleteCache() {
        Chat.cacheDB.deleteCacheData()
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
        log.verbose("Try to send deliver message for a message id with this parameters: \n \(deliverInput)", context: "Chat")
        
        if let theUserInfo = userInfo {
            let userInfoJSON = theUserInfo.formatToJSON()
            if (deliverInput.ownerId != userInfoJSON["id"].intValue) {
                /*
                let sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.DELIVERY.rawValue,
                                               "content":           deliverInput.messageId,
                                               "typeCode":          deliverInput.typeCode ?? generalTypeCode,
                                               "pushMsgType":       3]
                */
                
                let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.DELIVERY.rawValue,
                                                    content:            "\(deliverInput.messageId ?? 0)",
                                                    metaData:           nil,
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
                                        callback:           nil,
                                        callbacks:          nil,
                                        sentCallback:       nil,
                                        deliverCallback:    nil,
                                        seenCallback:       nil,
                                        uniuqueIdCallback:  nil)
            }
        }
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
        log.verbose("Try to send deliver message for a message id with this parameters: \n \(seenInput)", context: "Chat")
        
        if let theUserInfo = userInfo {
            let userInfoJSON = theUserInfo.formatToJSON()
            if (seenInput.ownerId != userInfoJSON["id"].intValue) {
                /*
                let sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.SEEN.rawValue,
                                               "content":           seenInput.messageId,
                                               "typeCode":          seenInput.typeCode ?? generalTypeCode,
                                               "pushMsgType":       3]
                */
                
                let chatMessage = SendChatMessageVO(chatMessageVOType:  chatMessageVOTypes.SEEN.rawValue,
                                                    content:            "\(seenInput.messageId ?? 0)",
                                                    metaData:           nil,
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
                                        callback:           nil,
                                        callbacks:          nil,
                                        sentCallback:       nil,
                                        deliverCallback:    nil,
                                        seenCallback:       nil,
                                        uniuqueIdCallback:  nil)
            }
        }
    }
    
}
