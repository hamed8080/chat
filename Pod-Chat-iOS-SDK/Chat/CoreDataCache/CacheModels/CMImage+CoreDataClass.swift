//
//  CMImage+CoreDataClass.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 11/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//
//

import Foundation
import CoreData


public class CMImage: NSManagedObject {
    
    public func convertCMImageToImageObject() -> ImageObject {
        
        var actualHeight:   Int?
        var actualWidth:    Int?
        var height:         Int?
        var id:             Int?
        var width:          Int?
        
        
        func createVariables() {
            if let actualHeight2 = self.actualHeight as? Int {
                actualHeight = actualHeight2
            }
            if let actualWidth2 = self.actualWidth as? Int {
                actualWidth = actualWidth2
            }
            if let height2 = self.height as? Int {
                height = height2
            }
            if let id2 = self.id as? Int {
                id = id2
            }
            if let width2 = self.width as? Int {
                width = width2
            }
        }
        
        func createImageObjectModel() -> ImageObject {
            let uploadImageModel = ImageObject(actualHeight: actualHeight,
                                               actualWidth: actualWidth,
                                               hashCode: self.hashCode,
                                               height: height,
                                               id: id,
                                               name: self.name,
                                               width: width)
            return uploadImageModel
        }
        
        createVariables()
        let model = createImageObjectModel()
        
        return model
    }
    
}
