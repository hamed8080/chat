//
//  FileUploadEventModel.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 10/3/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation


open class FileUploadEventModel {
    
    public let type:            FileUploadEventTypes
    
    public let errorCode:       Int?
    public let errorMessage:    String?
    public let errorEvent:      Error?
    public let fileInfo:        FileInfo?
    public let fileObjectData:  Data?
    public let progress:        Float?
    public let userGroupHash:   String?
    public let uniqueId:        String?
    
    init(type:          FileUploadEventTypes,
         errorCode:     Int?,
         errorMessage:  String?,
         errorEvent:    Error?,
         fileInfo:      FileInfo,
         fileObjectData: Data?,
         progress:      Float?,
         userGroupHash: String?,
         uniqueId:      String?) {
        
        self.type           = type
        self.errorCode      = errorCode
        self.errorMessage   = errorMessage
        self.errorEvent     = errorEvent
        self.fileInfo       = fileInfo
        self.fileObjectData = fileObjectData
        self.progress       = progress
        self.userGroupHash  = userGroupHash
        self.uniqueId       = uniqueId
    }
    
}


open class FileInfo {
    
    public let fileName:    String
    public let fileSize:    Int64?
    
    init(fileName: String, fileSize: Int64?) {
        self.fileName   = fileName
        self.fileSize   = fileSize
    }
    
}


//open class FileInfo {
//
//    let id:             Int64
//    let name:           String
//    let hashCode:       String
//    let description:    String
//    let created:        String
//    let size:           Int64
//    let type:           String
//
//    init(json: JSON) {
//        self.id             = json["id"].int64Value
//        self.name           = json["name"].stringValue
//        self.hashCode       = json["hashCode"].stringValue
//        self.description    = json["description"].stringValue
//        self.created        = json["created"].stringValue
//        self.size           = json["size"].int64Value
//        self.type           = json["type"].stringValue
//    }
//
//    init(id:            Int64,
//         name:          String,
//         hashCode:      String,
//         description:   String,
//         created:       String,
//         size:          Int64,
//         type:          String) {
//
//        self.id             = id
//        self.name           = name
//        self.hashCode       = hashCode
//        self.description    = description
//        self.created        = created
//        self.size           = size
//        self.type           = type
//    }
//
//}
