//
//  UploadImage.swift
//  Chat
//
//  Created by Mahyar Zhiani on 8/5/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//


import Foundation
import SwiftyJSON


open class UploadImage {
    
    public let actualHeight:   Int?
    public let actualWidth:    Int?
    public let hashCode:       String?
    public let height:         Int?
    public let id:             Int?
    public let name:           String?
    public let width:          Int?
    
    public init(messageContent: JSON) {
        self.actualHeight   = messageContent["actualHeight"].int
        self.actualWidth    = messageContent["actualWidth"].int
        self.hashCode       = messageContent["hashCode"].string
        self.height         = messageContent["height"].int
        self.id             = messageContent["id"].int
        self.name           = messageContent["name"].string
        self.width          = messageContent["width"].int
    }
    
    public init(actualHeight:  Int?,
                actualWidth:   Int?,
                hashCode:      String?,
                height:        Int?,
                id:            Int?,
                name:          String?,
                width:         Int?) {
        
        self.actualHeight   = actualHeight
        self.actualWidth    = actualWidth
        self.hashCode       = hashCode
        self.height         = height
        self.id             = id
        self.name           = name
        self.width          = width
    }
    
    public init(theUploadImage: UploadImage) {
        
        self.actualHeight   = theUploadImage.actualHeight
        self.actualWidth    = theUploadImage.actualWidth
        self.hashCode       = theUploadImage.hashCode
        self.height         = theUploadImage.height
        self.id             = theUploadImage.id
        self.name           = theUploadImage.name
        self.width          = theUploadImage.width
    }
    
    
    public func formatDataToMakeUploadImage() -> UploadImage {
        return self
    }
    
    public func formatToJSON() -> JSON {
        let result: JSON = ["actualHeight": actualHeight ?? NSNull(),
                            "actualWidth":  actualWidth ?? NSNull(),
                            "hashCode":     hashCode ?? NSNull(),
                            "height":       height ?? NSNull(),
                            "id":           id ?? NSNull(),
                            "name":         name ?? NSNull(),
                            "width":        width ?? NSNull()]
        return result
    }
    
}
