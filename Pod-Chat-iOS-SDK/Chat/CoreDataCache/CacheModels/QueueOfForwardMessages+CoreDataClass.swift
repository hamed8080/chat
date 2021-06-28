//
//  QueueOfForwardMessages+CoreDataClass.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 11/27/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//
//

import Foundation
import CoreData
import SwiftyJSON


public class QueueOfForwardMessages: NSManagedObject {
    
	@available(*,deprecated , message:"Removed in 0.10.5.0 version")
    public func convertCMObjectToObject() -> QueueOfWaitForwardMessagesModel {
        
//        var metadata:       JSON?
//        var messageIds:     [Int]?
        var messageId:      Int?
        var repliedTo:      Int?
        var threadId:       Int?
        
        func createVariables() {
            
//            self.metadata?.retrieveJSONfromTransformableData(completion: { (returnedJSON) in
//                metadata = returnedJSON
//            })
            
//            if let messageIds2 = self.messageIds as? [Int] {
            if let messageIds2 = self.messageId as? Int {
                messageId = messageIds2
            }
            
            if let repliedTo2 = self.repliedTo as? Int {
                repliedTo = repliedTo2
            }
            if let threadId2 = self.threadId as? Int {
                threadId = threadId2
            }
            
        }
        
        func createQueueOfWaitForwardtMessagesModel() -> QueueOfWaitForwardMessagesModel {
            let queueOfWaitForwardMessagesModel = QueueOfWaitForwardMessagesModel(//messageIds:   messageIds,
                                                                                  messageId:    messageId,
//                                                                                  metadata:     metadata,
                                                                                  metadata:     self.metadata,
                                                                                  repliedTo:    repliedTo,
                                                                                  threadId:     threadId,
                                                                                  typeCode:     self.typeCode,
                                                                                  uniqueId:     self.uniqueId)
            return queueOfWaitForwardMessagesModel
        }
        
        createVariables()
        let model = createQueueOfWaitForwardtMessagesModel()
        
        return model
    }
    
}
