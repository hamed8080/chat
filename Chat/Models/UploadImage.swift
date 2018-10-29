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
    
    let actualHeight:   Int?
    let actualWidth:    Int?
    let hashCode:       String?
    let height:         Int?
    let id:             Int?
    let name:           String?
    let width:          Int?
    
    init(messageContent: JSON) {
        self.actualHeight   = messageContent["actualHeight"].int
        self.actualWidth    = messageContent["actualWidth"].int
        self.hashCode       = messageContent["hashCode"].string
        self.height         = messageContent["height"].int
        self.id             = messageContent["id"].int
        self.name           = messageContent["name"].string
        self.width          = messageContent["width"].int
    }
    
    func formatDataToMakeUploadImage() -> UploadImage {
        return self
    }
    
    func formatToJSON() -> JSON {
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
