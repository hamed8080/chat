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
    
    
    /*
     Deliver:
     send deliver for some message.
     
     By calling this function, a request of type 4 (DELIVERY) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some optional prameters as an input, as JSON or Model (depends on the function that you would use) which are:
     - messageId:
     - ownerId:
     - typeCode:
     
     + Outputs:
     this function has no output!
     */
    public func deliver(deliverInput: DeliverSeenRequestModel) {
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
                                                    typeCode:           deliverInput.requestTypeCode ?? generalTypeCode,
                                                    uniqueId:           nil,
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
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'DeliverSeenRequestModel' to get the parameters, it'll use JSON
    /*
    public func deliver(params: JSON) {
        log.verbose("Try to send deliver message for a message id with this parameters: \n \(params)", context: "Chat")
        
        if let theUserInfo = userInfo {
            let userInfoJSON = theUserInfo.formatToJSON()
            if (params["ownerId"].intValue != userInfoJSON["id"].intValue) {
                let sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.DELIVERY.rawValue,
                                               "content":           params["messageId"].intValue,
                                               "typeCode":          params["typeCode"].int ?? generalTypeCode,
                                               "pushMsgType":       3]
                sendMessageWithCallback(params:             sendMessageParams,
                                        callback:           nil,
                                        callbacks:          nil,
                                        sentCallback:       nil,
                                        deliverCallback:    nil,
                                        seenCallback:       nil,
                                        uniuqueIdCallback:  nil)
            }
        }
    }
    */
    
    
    /*
     Seen:
     send seen for some message.
     
     By calling this function, a request of type 5 (SEEN) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some optional prameters as an input, as JSON or Model (depends on the function that you would use) which are:
     - messageId:
     - ownerId:
     - typeCode:
     
     + Outputs:
     this function has no output!
     */
    public func seen(seenInput: DeliverSeenRequestModel) {
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
                                                    typeCode:           seenInput.requestTypeCode ?? generalTypeCode,
                                                    uniqueId:           nil,
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
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'DeliverSeenRequestModel' to get the parameters, it'll use JSON
    /*
    public func seen(params: JSON) {
        log.verbose("Try to send deliver message for a message id with this parameters: \n \(params)", context: "Chat")
        
        if let theUserInfo = userInfo {
            let userInfoJSON = theUserInfo.formatToJSON()
            if (params["ownerId"].intValue != userInfoJSON["id"].intValue) {
                let sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.SEEN.rawValue,
                                               "content":           params["messageId"].intValue,
                                               "typeCode":          params["typeCode"].string ?? generalTypeCode,
                                               "pushMsgType":       3]
                sendMessageWithCallback(params:             sendMessageParams,
                                        callback:           nil,
                                        callbacks:          nil,
                                        sentCallback:       nil,
                                        deliverCallback:    nil,
                                        seenCallback:       nil,
                                        uniuqueIdCallback:  nil)
            }
        }
    }
    */
    
    
    
}
