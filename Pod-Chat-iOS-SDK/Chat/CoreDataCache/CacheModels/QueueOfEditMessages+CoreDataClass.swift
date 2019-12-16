//
//  QueueOfEditMessages+CoreDataClass.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 11/28/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//
//

import Foundation
import CoreData
import SwiftyJSON


public class QueueOfEditMessages: NSManagedObject {
    
    public func convertQueueOfEditMessagesToQueueOfWaitEditMessagesModelObject() -> QueueOfWaitEditMessagesModel {
        
        var metadata:       JSON?
        var repliedTo:      Int?
        var messageId:      Int?
        var threadId:       Int?
        
        func createVariables() {
            
            self.metadata?.retrieveJSONfromTransformableData(completion: { (returnedJSON) in
                metadata = returnedJSON
            })
            
            if let repliedTo2 = self.repliedTo as? Int {
                repliedTo = repliedTo2
            }
            if let messageId2 = self.messageId as? Int {
                messageId = messageId2
            }
            if let threadId2 = self.threadId as? Int {
                threadId = threadId2
            }
            
        }
        
        func createQueueOfWaitEditMessagesModel() -> QueueOfWaitEditMessagesModel {
            let queueOfWaitEditMessagesModel = QueueOfWaitEditMessagesModel(content:    self.content,
                                                                            metadata:   metadata,
                                                                            repliedTo:  repliedTo,
                                                                            messageId:  messageId,
                                                                            threadId:   threadId,
                                                                            typeCode:   self.typeCode,
                                                                            uniqueId:   self.uniqueId)
            return queueOfWaitEditMessagesModel
        }
        
        createVariables()
        let model = createQueueOfWaitEditMessagesModel()
        
        return model
    }
    
}
