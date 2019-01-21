//
//  CMUploadFile+CoreDataClass.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 11/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//
//

import Foundation
import CoreData


public class CMUploadFile: NSManagedObject {
    
    public func convertCMUploadFileToUploadFileObject() -> UploadFile {
        
        var id:             Int?
        
        func createVariables() {
            if let id2 = self.id as? Int {
                id = id2
            }
        }
        
        func createUploadFileModel() -> UploadFile {
            let uploadFileModel = UploadFile(hashCode:  self.hashCode,
                                             id:        id,
                                             name:      self.name)
            return uploadFileModel
        }
        
        createVariables()
        let model = createUploadFileModel()
        
        return model
    }
    
}
