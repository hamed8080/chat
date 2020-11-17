//
//  QueueOfWaitUploadFilesResponse.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 11/28/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class QueueOfWaitUploadFilesModel {
    
    let dataToSend:     Data?
    let fileExtension:  String?
    let fileName:       String?
    let fileSize:       Int64?
    let isPublic:       Bool?
    let mimeType:       String
    let originalName:   String?
    let userGroupHash:  String?
    let typeCode:       String?
    let uniqueId:       String?
    
    init(dataToSend:    Data?,
         fileExtension: String?,
         fileName:      String?,
         fileSize:      Int64?,
         isPublic:      Bool?,
         mimeType:      String?,
         originalName:  String?,
         userGroupHash: String?,
         typeCode:      String?,
         uniqueId:      String?) {
        
        self.dataToSend     = dataToSend
        self.fileExtension  = fileExtension
        self.fileName       = fileName
        self.fileSize       = fileSize
        self.isPublic       = isPublic
        self.mimeType       = mimeType ?? ""
        self.originalName   = originalName ?? ((fileName ?? "")+(fileExtension ?? ""))
        self.userGroupHash  = userGroupHash
        self.typeCode       = typeCode
        self.uniqueId       = uniqueId
        
    }
    
    init(fileInputModel: UploadFileRequestModel) {
        self.dataToSend     = fileInputModel.dataToSend
        self.fileExtension  = fileInputModel.fileExtension
        self.fileName       = fileInputModel.fileName
        self.fileSize       = fileInputModel.fileSize
        self.isPublic       = fileInputModel.isPublic
        self.mimeType       = fileInputModel.mimeType
        self.originalName   = fileInputModel.originalName
        self.userGroupHash  = fileInputModel.userGroupHash
        self.typeCode       = fileInputModel.typeCode
        self.uniqueId       = fileInputModel.uniqueId
    }
    
    
    public func returnDataAsJSONAndData() -> (jsonResult: JSON, fileToSend: Data?) {
        let result: JSON = ["fileExtension":    fileExtension ?? NSNull(),
                            "fileName":         fileName ?? NSNull(),
                            "fileSize":         fileSize ?? NSNull(),
                            "isPublic":         isPublic ?? NSNull(),
                            "mimeType":         mimeType,
                            "originalName":     originalName ?? NSNull(),
                            "userGroupHash":    userGroupHash ?? NSNull(),
                            "typeCode":         typeCode ?? NSNull(),
                            "uniqueId":         uniqueId ?? NSNull()]
        return (result, dataToSend)
    }
    
}


open class QueueOfWaitUploadFilesResponse: QueueOfWaitUploadFilesModel {
    
}


