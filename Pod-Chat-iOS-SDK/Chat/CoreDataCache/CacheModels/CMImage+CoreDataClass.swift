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
    
    @available(*,deprecated , message:"Removed in 0.10.5.0 version")
    public func convertCMObjectToObject() -> ImageObject {
        
        var actualHeight:   Int?
        var actualWidth:    Int?
        var height:         Int?
//        var id:             Int?
        var size:           Int?
        var width:          Int?
        
        
        func createVariables() {
            if let actualHeight_ = self.actualHeight as? Int {
                actualHeight = actualHeight_
            }
            if let actualWidth_ = self.actualWidth as? Int {
                actualWidth = actualWidth_
            }
            if let height_ = self.height as? Int {
                height = height_
            }
//            if let id2 = self.id as? Int {
//                id = id2
//            }
            if let size_ = self.size as? Int {
                size = size_
            }
            if let width_ = self.width as? Int {
                width = width_
            }
        }
        
        func createImageObjectModel() -> ImageObject {
            let uploadImageModel = ImageObject(actualHeight: actualHeight,
                                               actualWidth: actualWidth,
                                               hashCode: self.hashCode!,
                                               height: height,
//                                               id: id!,
                                               name: self.name,
                                               size: size,
                                               width: width)
            return uploadImageModel
        }
        
        createVariables()
        let model = createImageObjectModel()
        
        return model
    }
    
}
