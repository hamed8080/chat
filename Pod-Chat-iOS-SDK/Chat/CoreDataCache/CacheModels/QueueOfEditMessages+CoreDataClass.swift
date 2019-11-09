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
        
        var metaData:       JSON?
        var repliedTo:      Int?
        var subjectId:      Int?
        
        func createVariables() {
            
            self.metaData?.retrieveJSONfromTransformableData(completion: { (returnedJSON) in
                metaData = returnedJSON
            })
            
            if let repliedTo2 = self.repliedTo as? Int {
                repliedTo = repliedTo2
            }
            if let subjectId2 = self.subjectId as? Int {
                subjectId = subjectId2
            }
            
        }
        
        func createQueueOfWaitEditMessagesModel() -> QueueOfWaitEditMessagesModel {
            let queueOfWaitEditMessagesModel = QueueOfWaitEditMessagesModel(content:            self.content,
                                                                            metaData:           metaData,
                                                                            repliedTo:          repliedTo,
                                                                            subjectId:          subjectId,
                                                                            requestTypeCode:    self.typeCode,
                                                                            requestUniqueId:    self.uniqueId)
            return queueOfWaitEditMessagesModel
        }
        
        createVariables()
        let model = createQueueOfWaitEditMessagesModel()
        
        return model
    }
    
}
