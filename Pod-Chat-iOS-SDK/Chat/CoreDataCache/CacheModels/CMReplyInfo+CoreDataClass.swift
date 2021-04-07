//
//  CMReplyInfo+CoreDataClass.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 11/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//
//

import Foundation
import CoreData


public class CMReplyInfo: NSManagedObject {
    
	@available(*,deprecated , message:"Removed in XX.XX.XX version")
    public func convertCMObjectToObject() -> ReplyInfo {
        
        var deleted:            Bool?
        var repliedToMessageId: Int?
        var messageType:        Int?
        var time:               UInt?
        
        func createVariables() {
            if let deleted2 = self.deletedd as? Bool {
                deleted = deleted2
            }
            if let repliedToMessageId2 = self.repliedToMessageId as? Int {
                repliedToMessageId = repliedToMessageId2
            }
            if let messageType2 = self.messageType as? Int {
                messageType = messageType2
            }
            if let time2 = self.time as? UInt {
                time = time2
            }
        }
        
        func createMessageModel() -> ReplyInfo {
            let replyInfoModel = ReplyInfo(deleted: deleted,
                                           repliedToMessageId: repliedToMessageId,
                                           message:         self.message,
                                           messageType:     messageType,
                                           metadata:        self.metadata,
                                           systemMetadata:  self.systemMetadata,
                                           time:            time,
                                           participant:     participant?.convertCMObjectToObject())
            
            return replyInfoModel
        }
        
        createVariables()
        let model = createMessageModel()
        
        return model
    }
    
	@available(*,deprecated , message:"Removed in XX.XX.XX version")
    func updateObject(with replyInfo: ReplyInfo, messageId: Int) {
        self.messageId          = messageId as NSNumber?
        self.deletedd           = replyInfo.deleted as NSNumber?
        self.message            = replyInfo.message
        self.messageType        = replyInfo.messageType as NSNumber?
        self.metadata           = replyInfo.metadata
        self.repliedToMessageId = replyInfo.repliedToMessageId as NSNumber?
        self.systemMetadata     = replyInfo.systemMetadata
        self.time               = replyInfo.time as NSNumber?
    }
    
}
