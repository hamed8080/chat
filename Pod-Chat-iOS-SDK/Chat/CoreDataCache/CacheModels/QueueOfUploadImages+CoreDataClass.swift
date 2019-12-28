//
//  QueueOfUploadImages+CoreDataClass.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 11/28/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//
//

import Foundation
import CoreData


public class QueueOfUploadImages: NSManagedObject {
    
    public func convertQueueOfUploadImagesToQueueOfWaitUploadImagesModelObject() -> QueueOfWaitUploadImagesModel {
        
        var dataToSend: Data?
        var fileSize:   Int?
        var threadId:   Int?
        var xC:         Int?
        var yC:         Int?
        var hC:         Int?
        var wC:         Int?
        
        func createVariables() {
            if let dataToSend2 = self.dataToSend as Data? {
                dataToSend = dataToSend2
            }
            if let fileSize2 = self.fileSize as? Int {
                fileSize = fileSize2
            }
            if let threadId2 = self.threadId as? Int {
                threadId = threadId2
            }
            if let xC2 = self.xC as? Int {
                xC = xC2
            }
            if let yC2 = self.yC as? Int {
                yC = yC2
            }
            if let hC2 = self.hC as? Int {
                hC = hC2
            }
            if let wC2 = self.wC as? Int {
                wC = wC2
            }
        }
        
        func createQueueOfWaitUploadImagesModel() -> QueueOfWaitUploadImagesModel {
            let queueOfWaitUploadImagesModel = QueueOfWaitUploadImagesModel(dataToSend:         dataToSend,
                                                                            fileExtension:      self.fileExtension,
                                                                            fileName:           self.fileName,
                                                                            fileSize:           fileSize,
                                                                            originalFileName:   self.originalFileName,
                                                                            threadId:           threadId,
                                                                            xC:                 xC,
                                                                            yC:                 yC,
                                                                            hC:                 hC,
                                                                            wC:                 wC,
                                                                            typeCode:           self.typeCode,
                                                                            uniqueId:           self.uniqueId)
            return queueOfWaitUploadImagesModel
        }
        
        createVariables()
        let model = createQueueOfWaitUploadImagesModel()
        
        return model
    }
    
}
