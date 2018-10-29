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
    
    let hashCode:       String?
    let id:             Int?
    let name:           String?
    
    init(messageContent: JSON) {
        self.hashCode       = messageContent["hashCode"].string
        self.id             = messageContent["id"].int
        self.name           = messageContent["name"].string
    }
    
    func formatDataToMakeUploadImage() -> UploadFile {
        return self
    }
    
    func formatToJSON() -> JSON {
        let result: JSON = ["hashCode":     hashCode ?? NSNull(),
                            "id":           id ?? NSNull(),
                            "name":         name ?? NSNull()]
        return result
    }
    
}


