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
    
    public func convertCMObjectToObject() -> QueueOfWaitUploadImagesModel {
        
        var dataToSend: Data?
        var fileSize:   Int64?
        var isPublic:   Bool?
        var xC:         Int?
        var yC:         Int?
        var hC:         Int?
        var wC:         Int?
        
        func createVariables() {
            if let dataToSend_ = self.dataToSend as Data? {
                dataToSend = dataToSend_
            }
            if let fileSize_ = self.fileSize as? Int64 {
                fileSize = fileSize_
            }
            if let isPublic_ = self.isPublic as? Bool {
                isPublic = isPublic_
            }
            if let xC_ = self.xC as? Int {
                xC = xC_
            }
            if let yC_ = self.yC as? Int {
                yC = yC_
            }
            if let hC_ = self.hC as? Int {
                hC = hC_
            }
            if let wC_ = self.wC as? Int {
                wC = wC_
            }
        }
        
        func createQueueOfWaitUploadImagesModel() -> QueueOfWaitUploadImagesModel {
            let queueOfWaitUploadImagesModel = QueueOfWaitUploadImagesModel(dataToSend:     dataToSend,
                                                                            fileExtension:  self.fileExtension,
                                                                            fileName:       self.fileName,
                                                                            fileSize:       fileSize,
                                                                            isPublic:       isPublic,
                                                                            mimeType:       self.mimeType,
                                                                            originalName:   self.originalName,
                                                                            userGroupHash:  self.userGroupHash,
                                                                            xC:             xC ?? 0,
                                                                            yC:             yC ?? 0,
                                                                            hC:             hC ?? 99999,
                                                                            wC:             wC ?? 99999,
                                                                            typeCode:       self.typeCode,
                                                                            uniqueId:       self.uniqueId)
            return queueOfWaitUploadImagesModel
        }
        
        createVariables()
        let model = createQueueOfWaitUploadImagesModel()
        
        return model
    }
    
}
