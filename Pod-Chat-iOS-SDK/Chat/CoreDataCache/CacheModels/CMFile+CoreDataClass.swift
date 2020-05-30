//
//  CMFile+CoreDataClass.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 11/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//
//

import Foundation
import CoreData


public class CMFile: NSManagedObject {
    
    public func convertCMObjectToObject() -> FileObject {
        
        var id:     Int?
        var size:   Int?
        
        func createVariables() {
            if let id_ = self.id as? Int {
                id = id_
            }
            if let size_ = self.size as? Int {
                size = size_
            }
        }
        
        func createFileObjectModel() -> FileObject {
            let uploadFileModel = FileObject(hashCode:  self.hashCode!,
                                             id:        id!,
                                             name:      self.name,
                                             size:      size,
                                             type:      type)
            return uploadFileModel
        }
        
        createVariables()
        let model = createFileObjectModel()
        
        return model
    }
    
}
