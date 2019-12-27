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
    public let threadId:        Int?
    public let uniqueId:        String?
    
    init(type: FileUploadEventTypes, errorCode: Int?, errorMessage: String?, errorEvent: Error?, fileInfo: FileInfo, fileObjectData: Data?, progress: Float?, threadId: Int?, uniqueId: String?) {
        self.type           = type
        self.errorCode      = errorCode
        self.errorMessage   = errorMessage
        self.errorEvent     = errorEvent
        self.fileInfo       = fileInfo
        self.fileObjectData = fileObjectData
        self.progress       = progress
        self.threadId       = threadId
        self.uniqueId       = uniqueId
    }
    
}


open class FileInfo {
    
    public let fileName:    String
    public let fileSize:    Int?
    
    init(fileName: String, fileSize: Int?) {
        self.fileName   = fileName
        self.fileSize   = fileSize
    }
    
}
