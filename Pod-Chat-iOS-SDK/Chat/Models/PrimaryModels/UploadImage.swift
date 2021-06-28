//
//  UploadImage.swift
//  Chat
//
//  Created by Mahyar Zhiani on 8/5/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


open class ImageObject {
    
    public var actualHeight:   Int?
    public var actualWidth:    Int?
    public var hashCode:       String
    public var height:         Int?
//    public var id:             Int
    public var name:           String?
    public var size:           Int?
    public var width:          Int?
    
    @available(*,deprecated , message:"Removed in 0.10.5.0 version")
    public init(messageContent: JSON) {
        self.actualHeight   = messageContent["actualHeight"].int
        self.actualWidth    = messageContent["actualWidth"].int
        self.hashCode       = messageContent["hashCode"].stringValue
        self.height         = messageContent["height"].int
//        self.id             = messageContent["id"].intValue
        self.name           = messageContent["name"].string
        self.size           = messageContent["size"].int
        self.width          = messageContent["width"].int
    }
    
    public init(actualHeight:  Int?,
                actualWidth:   Int?,
                hashCode:      String,
                height:        Int?,
//                id:            Int,
                name:          String?,
                size:          Int?,
                width:         Int?) {
        
        self.actualHeight   = actualHeight
        self.actualWidth    = actualWidth
        self.hashCode       = hashCode
        self.height         = height
//        self.id             = id
        self.name           = name
        self.size           = size
        self.width          = width
    }

    @available(*,deprecated , message:"Removed in 0.10.5.0 version")
    public init(theUploadImage: ImageObject) {
        
        self.actualHeight   = theUploadImage.actualHeight
        self.actualWidth    = theUploadImage.actualWidth
        self.hashCode       = theUploadImage.hashCode
        self.height         = theUploadImage.height
//        self.id             = theUploadImage.id
        self.name           = theUploadImage.name
        self.size           = theUploadImage.size
        self.width          = theUploadImage.width
    }
    
    @available(*,deprecated , message:"Removed in 0.10.5.0 version")
    public func formatDataToMakeUploadImage() -> ImageObject {
        return self
    }
    
    @available(*,deprecated , message:"Removed in 0.10.5.0 version")
    public func formatToJSON() -> JSON {
        let result: JSON = ["actualHeight": actualHeight ?? NSNull(),
                            "actualWidth":  actualWidth ?? NSNull(),
                            "hashCode":     hashCode,
                            "height":       height ?? NSNull(),
//                            "id":           id,
                            "name":         name ?? NSNull(),
                            "size":         size ?? NSNull(),
                            "width":        width ?? NSNull()]
        return result
    }
    
}
