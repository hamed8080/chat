//
//  UploadFile.swift
//  Chat
//
//  Created by Mahyar Zhiani on 8/5/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class FileObject {
    
    public var hashCode:       String
//    public var id:             Int
    public var name:           String?
    public var size:           Int?
    public var type:           String?
    
    public init(messageContent: JSON) {
        self.hashCode       = messageContent["hashCode"].stringValue
//        self.id             = messageContent["id"].intValue
        self.name           = messageContent["name"].string
        self.size           = messageContent["size"].int
        self.type           = messageContent["type"].string
    }
    
    public init(hashCode:   String,
//                id:         Int,
                name:       String?,
                size:       Int?,
                type:       String?) {
        
        self.hashCode       = hashCode
//        self.id             = id
        self.name           = name
        self.size           = size
        self.type           = type
    }
    
    public init(theUploadFile: FileObject) {
        
        self.hashCode       = theUploadFile.hashCode
//        self.id             = theUploadFile.id
        self.name           = theUploadFile.name
        self.size           = theUploadFile.size
        self.type           = theUploadFile.type
    }
    
    
    public func formatDataToMakeUploadImage() -> FileObject {
        return self
    }
    
    public func formatToJSON() -> JSON {
        let result: JSON = ["hashCode":     hashCode,
//                            "id":           id,
                            "name":         name ?? NSNull(),
                            "size":         size ?? NSNull(),
                            "type":         type ?? NSNull()]
        return result
    }
    
}


