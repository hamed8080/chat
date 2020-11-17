//
//  UploadFileRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Alamofire
import SwiftyJSON

open class UploadFileRequest: UploadRequest {
    
    /// initializer of Uploading File request model
    public init(dataToSend:     Data,
                fileExtension:  String?,
                fileName:       String?,
                mimeType:       String?,
                originalName:   String?,
                userGroupHash:  String?,
                typeCode:       String?,
                uniqueId:       String?) {
        
        super.init(typeCode: typeCode, uniqueId: uniqueId)
        
        self.dataToSend     = dataToSend
        self.fileExtension  = fileExtension
        self.fileName       = fileName ?? "\(NSUUID().uuidString))"
        self.fileSize       = Int64(dataToSend.count)
        self.mimeType       = mimeType ?? ""
        self.userGroupHash  = userGroupHash
        self.originalName   = originalName ?? (self.fileName + (fileExtension ?? ""))
    }
    
    /// only use this initializer on, createThreadWithFileMessage & sendFileMessage methods
    public init(dataToSend:     Data,
                fileExtension:  String?,
                fileName:       String?,
                mimeType:       String?,
                originalName:   String?,
                typeCode:       String?,
                uniqueId:       String?) {
        
        super.init(typeCode: typeCode, uniqueId: uniqueId)
        
        self.dataToSend     = dataToSend
        self.fileExtension  = fileExtension
        self.fileName       = fileName ?? "\(NSUUID().uuidString))"
        self.fileSize       = Int64(dataToSend.count)
        self.mimeType       = mimeType ?? ""
        self.userGroupHash  = userGroupHash
        self.originalName   = originalName ?? (self.fileName + (fileExtension ?? ""))
    }
    
    /// initializer of Uploading Public File request model
    public init(dataToSend:     Data,
                fileExtension:  String?,
                fileName:       String?,
                isPublic:       Bool,
                mimeType:       String?,
                originalName:   String?,
                typeCode:       String?,
                uniqueId:       String?) {
        
        super.init(typeCode: typeCode, uniqueId: uniqueId)
        
        self.dataToSend     = dataToSend
        self.fileExtension  = fileExtension
        self.fileName       = fileName ?? "\(NSUUID().uuidString))"
        self.fileSize       = Int64(dataToSend.count)
        self.isPublic       = isPublic
        self.mimeType       = mimeType ?? ""
        self.originalName   = originalName ?? (self.fileName + (fileExtension ?? ""))
    }
    
    
    func convertContentToParameters() -> Parameters {
        
        var content: Parameters = [:]
        
        content["filename"] = JSON(self.fileName)
        if let userGroupHash_ = userGroupHash {
            content["userGroupHash"] = JSON(userGroupHash_)
        }
        if let isPublic_ = isPublic {
            content["isPublic"] = JSON(isPublic_)
        }
        
        return content
    }
    
}


open class UploadFileRequestModel: UploadFileRequest {
    
}

