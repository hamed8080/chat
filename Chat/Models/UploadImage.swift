//
//  UploadImage.swift
//  Chat
//
//  Created by Mahyar Zhiani on 8/5/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//


import Foundation
import SwiftyJSON


class UploadImage {
    
    let id:             Int?
    let name:           String?
    let height:         Int?
    let width:          Int?
    let actualHeight:   Int?
    let actualWidth:    Int?
    let hashCode:       String?
    
    init(messageContent: JSON) {
        self.id             = messageContent["id"].int
        self.name           = messageContent["name"].string
        self.height         = messageContent["height"].int
        self.width          = messageContent["width"].int
        self.actualHeight   = messageContent["actualHeight"].int
        self.actualWidth    = messageContent["actualWidth"].int
        self.hashCode       = messageContent["hashCode"].string
    }
    
    func formatDataToMakeUploadImage() -> UploadImage {
        return self
    }
    
    func formatToJSON() -> JSON {
        let result: JSON = ["id":           id ?? NSNull(),
                            "name":         name ?? NSNull(),
                            "height":       height ?? NSNull(),
                            "width":        width ?? NSNull(),
                            "actualHeight": actualHeight ?? NSNull(),
                            "actualWidth":  actualWidth ?? NSNull(),
                            "hashCode":     hashCode ?? NSNull()]
        return result
    }
    
}
