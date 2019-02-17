//
//  QueueOfFileMessages+CoreDataClass.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 11/27/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//
//

import Foundation
import CoreData
import SwiftyJSON

public class QueueOfFileMessages: NSManagedObject {
    
    public func convertQueueOfFileMessagesToQueueOfWaitFileMessagesModelObject() -> QueueOfWaitFileMessagesModel {
        
        var fileToSend:     Data?
        var imageToSend:    Data?
        var metaData:       JSON?
        var repliedTo:      Int?
        var subjectId:      Int?
        var threadId:       Int?
        
        func createVariables() {
            if let fileToSend2 = self.fileToSend as Data? {
                fileToSend = fileToSend2
            }
            if let imageToSend2 = self.imageToSend as Data? {
                imageToSend = imageToSend2
            }
            
            self.metaData?.retrieveJSONfromTransformableData(completion: { (returnedJSON) in
                metaData = returnedJSON
            })
            
            if let repliedTo2 = self.repliedTo as? Int {
                repliedTo = repliedTo2
            }
            if let subjectId2 = self.subjectId as? Int {
                subjectId = subjectId2
            }
            if let threadId2 = self.threadId as? Int {
                threadId = threadId2
            }
        }
        
        func createQueueOfWaitFileMessagesModel() -> QueueOfWaitFileMessagesModel {
            let queueOfWaitFileMessagesModel = QueueOfWaitFileMessagesModel(content:    self.content,
                                                                            fileName:   self.fileName,
                                                                            imageName:  self.imageName,
                                                                            metaData:   metaData,
                                                                            repliedTo:  repliedTo,
                                                                            subjectId:  subjectId,
                                                                            threadId:   threadId,
                                                                            typeCode:   self.typeCode,
                                                                            uniqueId:   self.uniqueId,
                                                                            xC:         self.xC,
                                                                            yC:         self.yC,
                                                                            hC:         self.hC,
                                                                            wC:         self.wC,
                                                                            fileToSend: fileToSend,
                                                                            imageToSend: imageToSend)
            return queueOfWaitFileMessagesModel
        }
        
        createVariables()
        let model = createQueueOfWaitFileMessagesModel()
        
        return model
    }
    
}
