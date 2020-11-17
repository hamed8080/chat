//
//  QueueOfUploadFiles+CoreDataClass.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 11/28/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//
//

import Foundation
import CoreData


public class QueueOfUploadFiles: NSManagedObject {
    
    public func convertCMObjectToObject() -> QueueOfWaitUploadFilesModel {
        
        var dataToSend: Data?
        var fileSize:   Int64?
        var isPublic:   Bool?
        
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
        }
        
        func createQueueOfWaitUploadFilesModel() -> QueueOfWaitUploadFilesModel {
            let queueOfWaitUploadFilesModel = QueueOfWaitUploadFilesModel(dataToSend:       dataToSend,
                                                                          fileExtension:    self.fileExtension,
                                                                          fileName:         self.fileName,
                                                                          fileSize:         fileSize,
                                                                          isPublic:         isPublic,
                                                                          mimeType:         self.mimeType,
                                                                          originalName:     self.originalName,
                                                                          userGroupHash:    self.userGroupHash,
                                                                          typeCode:         self.typeCode,
                                                                          uniqueId:         self.uniqueId)
            return queueOfWaitUploadFilesModel
        }
        
        createVariables()
        let model = createQueueOfWaitUploadFilesModel()
        
        return model
    }
    
}
