//
//  FileUploadEventModel.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
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

public enum FileUploadEventTypes {
    case NOT_STARTED
    case UPLOADING
    case UPLOADED
    case UPLOAD_ERROR
}
