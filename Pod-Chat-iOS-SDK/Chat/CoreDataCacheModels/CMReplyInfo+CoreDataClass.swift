//
//  CMReplyInfo+CoreDataClass.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//
//

import Foundation
import CoreData


public class CMReplyInfo: NSManagedObject {
    
    public func convertCMReplyInfoToReplyInfoObject() -> ReplyInfo {
        
        var deleted:             Bool?
        var repliedToMessageId:  Int?
        var messageType:         Int?
        
        
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
        }
        
        func createMessageModel() -> ReplyInfo {
            let replyInfoModel = ReplyInfo(deleted: deleted,
                                           repliedToMessageId: repliedToMessageId,
                                           message: self.message,
                                           messageType: messageType,
                                           metadata: self.metadata,
                                           systemMetadata: self.systemMetadata,
                                           participant: participant?.convertCMParticipantToParticipantObject())
            
            return replyInfoModel
        }
        
        createVariables()
        let model = createMessageModel()
        
        return model
    }
    
}
