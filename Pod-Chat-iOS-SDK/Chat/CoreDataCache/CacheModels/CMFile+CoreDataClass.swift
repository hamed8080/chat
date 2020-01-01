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
    
    public func convertCMFileToFileObject() -> FileObject {
        
        var id:             Int?
        
        func createVariables() {
            if let id2 = self.id as? Int {
                id = id2
            }
        }
        
        func createFileObjectModel() -> FileObject {
            let uploadFileModel = FileObject(hashCode:  self.hashCode!,
                                             id:        id!,
                                             name:      self.name)
            return uploadFileModel
        }
        
        createVariables()
        let model = createFileObjectModel()
        
        return model
    }
    
}
