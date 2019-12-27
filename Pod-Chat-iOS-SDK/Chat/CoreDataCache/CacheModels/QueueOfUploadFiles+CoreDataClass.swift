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
    
    public func convertQueueOfUploadFilesToQueueOfWaitUploadFilesModelObject() -> QueueOfWaitUploadFilesModel {
        
        var dataToSend: Data?
        var fileSize:   Int?
        var threadId:   Int?
        
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
        }
        
        func createQueueOfWaitUploadFilesModel() -> QueueOfWaitUploadFilesModel {
            let queueOfWaitUploadFilesModel = QueueOfWaitUploadFilesModel(dataToSend:       dataToSend,
                                                                          fileExtension:    self.fileExtension,
                                                                          fileName:         self.fileName,
                                                                          fileSize:         fileSize,
                                                                          originalFileName: self.originalFileName,
                                                                          threadId:         threadId,
                                                                          typeCode:         self.typeCode,
                                                                          uniqueId:         self.uniqueId)
            return queueOfWaitUploadFilesModel
        }
        
        createVariables()
        let model = createQueueOfWaitUploadFilesModel()
        
        return model
    }
    
}
