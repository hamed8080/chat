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
    
    let dataToSend:         Data?
    let fileExtension:      String?
    let fileName:           String?
    let fileSize:           Int64?
    let mimeType:           String
    let originalFileName:   String?
    let threadId:           Int?
    let typeCode:           String?
    let uniqueId:           String?
    
    init(dataToSend:        Data?,
         fileExtension:     String?,
         fileName:          String?,
         fileSize:          Int64?,
         mimeType:          String?,
         originalFileName:  String?,
         threadId:          Int?,
         typeCode:          String?,
         uniqueId:          String?) {
        
        self.dataToSend         = dataToSend
        self.fileExtension      = fileExtension
        self.fileName           = fileName
        self.fileSize           = fileSize
        self.mimeType           = mimeType ?? ""
        self.originalFileName   = originalFileName
        self.threadId           = threadId
        self.typeCode           = typeCode
        self.uniqueId           = uniqueId
        
    }
    
    init(fileInputModel: UploadFileRequestModel) {
        self.dataToSend         = fileInputModel.dataToSend
        self.fileExtension      = fileInputModel.fileExtension
        self.fileName           = fileInputModel.fileName
        self.fileSize           = fileInputModel.fileSize
        self.mimeType           = fileInputModel.mimeType
        self.originalFileName   = fileInputModel.originalFileName
        self.threadId           = fileInputModel.threadId
        self.typeCode           = fileInputModel.typeCode
        self.uniqueId           = fileInputModel.uniqueId
    }
    
    
    public func returnDataAsJSONAndData() -> (jsonResult: JSON, fileToSend: Data?) {
        let result: JSON = ["fileExtension":    fileExtension ?? NSNull(),
                            "fileName":         fileName ?? NSNull(),
                            "fileSize":         fileSize ?? NSNull(),
                            "mimeType":         mimeType,
                            "originalFileName": originalFileName ?? NSNull(),
                            "threadId":         threadId ?? NSNull(),
                            "typeCode":         typeCode ?? NSNull(),
                            "uniqueId":         uniqueId ?? NSNull()]
        return (result, dataToSend)
    }
    
}


open class QueueOfWaitUploadFilesResponse: QueueOfWaitUploadFilesModel {
    
}


