//
//  QueueOfTextMessages+CoreDataClass.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 11/27/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//
//

import Foundation
import CoreData
import SwiftyJSON


public class QueueOfTextMessages: NSManagedObject {
    
    public func convertQueueOfTextMessagesToQueueOfWaitTextMessagesModelObject() -> QueueOfWaitTextMessagesModel {
        
        var metaData:       JSON?
        var repliedTo:      Int?
        var threadId:       Int?
        var systemMetadata: JSON?
        
        func createVariables() {
            
            self.metaData?.retrieveJSONfromTransformableData(completion: { (returnedJSON) in
                metaData = returnedJSON
            })
            
            if let repliedTo2 = self.repliedTo as? Int {
                repliedTo = repliedTo2
            }
            if let threadId2 = self.threadId as? Int {
                threadId = threadId2
            }
            
            self.systemMetadata?.retrieveJSONfromTransformableData(completion: { (returnedJSON) in
                systemMetadata = returnedJSON
            })
            
        }
        
        func createQueueOfWaitTextMessagesModel() -> QueueOfWaitTextMessagesModel {
            let queueOfWaitTextMessagesModel = QueueOfWaitTextMessagesModel(content:            self.content,
                                                                            metaData:           metaData,
                                                                            repliedTo:          repliedTo,
                                                                            systemMetadata:     systemMetadata,
                                                                            threadId:           threadId,
                                                                            requestTypeCode:    self.typeCode,
                                                                            requestUniqueId:    self.uniqueId)
            return queueOfWaitTextMessagesModel
        }
        
        createVariables()
        let model = createQueueOfWaitTextMessagesModel()
        
        return model
    }
    
}
