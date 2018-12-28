//
//  UploadFile.swift
//  Chat
//
//  Created by Mahyar Zhiani on 8/5/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class UploadFile {
    
    public let hashCode:       String?
    public let id:             Int?
    public let name:           String?
    
    public init(messageContent: JSON) {
        self.hashCode       = messageContent["hashCode"].string
        self.id             = messageContent["id"].int
        self.name           = messageContent["name"].string
    }
    
    public init(hashCode:   String?,
                id:         Int?,
                name:       String?) {
        
        self.hashCode       = hashCode
        self.id             = id
        self.name           = name
    }
    
    public init(theUploadFile: UploadFile) {
        
        self.hashCode       = theUploadFile.hashCode
        self.id             = theUploadFile.id
        self.name           = theUploadFile.name
    }
    
    
    public func formatDataToMakeUploadImage() -> UploadFile {
        return self
    }
    
    public func formatToJSON() -> JSON {
        let result: JSON = ["hashCode":     hashCode ?? NSNull(),
                            "id":           id ?? NSNull(),
                            "name":         name ?? NSNull()]
        return result
    }
    
}


