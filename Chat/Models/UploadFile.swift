//
//  UploadFile.swift
//  Chat
//
//  Created by Mahyar Zhiani on 8/5/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

class UploadFile {
    
    let id:             Int?
    let name:           String?
    let hashCode:       String?
    
    init(messageContent: JSON) {
        self.id             = messageContent["id"].int
        self.name           = messageContent["name"].string
        self.hashCode       = messageContent["hashCode"].string
    }
    
    func formatDataToMakeUploadImage() -> UploadFile {
        return self
    }
    
    func formatToJSON() -> JSON {
        let result: JSON = ["id":           id ?? NSNull(),
                            "name":         name ?? NSNull(),
                            "hashCode":     hashCode ?? NSNull()]
        return result
    }
    
}


