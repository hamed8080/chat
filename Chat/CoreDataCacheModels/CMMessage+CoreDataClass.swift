//
//  CMMessage+CoreDataClass.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//
//

import Foundation
import CoreData


public class CMMessage: NSManagedObject {
    
    public func convertCMMessageToMessageObject() -> Message {
        
        
        
        var delivered:      Bool?
        var editable:       Bool?
        var edited:         Bool?
        var id:             Int?
        var ownerId:        Int?
        var previousId:     Int?
        var seen:           Bool?
        var threadId:       Int?
        var time:           Int?
        
        func createVariables() {
            if let delivered2 = self.delivered as? Bool {
                delivered = delivered2
            }
            if let editable2 = self.editable as? Bool {
                editable = editable2
            }
            if let edited2 = self.edited as? Bool {
                edited = edited2
            }
            if let id2 = self.id as? Int {
                id = id2
            }
            if let ownerId2 = self.ownerId as? Int {
                ownerId = ownerId2
            }
            if let previousId2 = self.previousId as? Int {
                previousId = previousId2
            }
            if let seen2 = self.seen as? Bool {
                seen = seen2
            }
            if let threadId2 = self.threadId as? Int {
                threadId = threadId2
            }
            if let time2 = self.time as? Int {
                time = time2
            }
        }
        
        func createMessageModel() -> Message {
            let messageModel = Message(threadId: threadId,
                                       delivered: delivered,
                                       editable: editable,
                                       edited: edited,
                                       id: id,
                                       message: self.message,
                                       metaData: self.metaData,
                                       ownerId: ownerId,
                                       previousId: previousId,
                                       seen: seen,
                                       time: time,
                                       uniqueId: self.uniqueId,
                                       conversation: conversation?.convertCMConversationToConversationObject(),
                                       forwardInfo: forwardInfo?.convertCMForwardInfoToForwardInfoObject(),
                                       participant: participant?.convertCMParticipantToParticipantObject(),
                                       replyInfo: replyInfo?.convertCMReplyInfoToReplyInfoObject())
            return messageModel
        }
        
        createVariables()
        let model = createMessageModel()
        
        return model
        
    }
    
}
