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
    
    public func convertCMObjectToObject() -> QueueOfWaitFileMessagesModel {
        
        var fileToSend:     Data?
        var imageToSend:    Data?
        var isPublic:       Bool?
        var repliedTo:      Int?
        var threadId:       Int?
        var messageType:    Int?
        
        var xC:       Int?
        var yC:       Int?
        var wC:       Int?
        var hC:       Int?
        
        func createVariables() {
            if let fileToSend2 = self.fileToSend as Data? {
                fileToSend = fileToSend2
            }
            if let imageToSend2 = self.imageToSend as Data? {
                imageToSend = imageToSend2
            }
            if let messageType2 = self.messageType as? Int {
                messageType = messageType2
            }
//            self.metadata?.retrieveJSONfromTransformableData(completion: { (returnedJSON) in
//                metadata = returnedJSON
//            })
            
            if let repliedTo2 = self.repliedTo as? Int {
                repliedTo = repliedTo2
            }
            if let isPublic_ = self.isPublic as? Bool {
                isPublic = isPublic_
            }
            if let threadId2 = self.threadId as? Int {
                threadId = threadId2
            }
            if let xC_ = self.xC as? Int {
                xC = xC_
            }
            if let yC_ = self.yC as? Int {
                yC = yC_
            }
            if let wC_ = self.wC as? Int {
                wC = wC_
            }
            if let hC_ = self.hC as? Int {
                hC = hC_
            }
        }
        
        func createQueueOfWaitFileMessagesModel() -> QueueOfWaitFileMessagesModel {
            let queueOfWaitFileMessagesModel = QueueOfWaitFileMessagesModel(textMessage:        self.textMessage,
                                                                            messageType:    MessageType.getType(from: messageType ?? 1),
                                                                            fileExtension:  self.fileExtension,
                                                                            fileName:       self.fileName,
                                                                            isPublic:       isPublic,
                                                                            metadata:       self.metadata,
                                                                            mimeType:       self.mimeType,
                                                                            originalName:   self.originalName,
                                                                            repliedTo:      repliedTo,
                                                                            threadId:       threadId,
                                                                            userGroupHash:  self.userGroupHash,
                                                                            xC:             xC,
                                                                            yC:             yC,
                                                                            hC:             hC,
                                                                            wC:             wC,
                                                                            fileToSend:     fileToSend,
                                                                            imageToSend:    imageToSend,
                                                                            typeCode:       self.typeCode,
                                                                            uniqueId:       self.uniqueId)
            return queueOfWaitFileMessagesModel
        }
        
        createVariables()
        let model = createQueueOfWaitFileMessagesModel()
        
        return model
    }
    
}
