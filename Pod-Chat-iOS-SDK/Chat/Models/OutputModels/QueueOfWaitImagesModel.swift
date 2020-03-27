//
//  QueueOfWaitImagesModel.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 11/28/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class QueueOfWaitUploadImagesModel {
    
    let dataToSend:       Data?
    let fileExtension:    String?
    let fileName:         String?
    let fileSize:         Int64?
    let mimeType:         String?
    let originalFileName: String?
    let threadId:         Int?
    let xC:               Int?
    let yC:               Int?
    let hC:               Int?
    let wC:               Int?
    let typeCode:         String?
    let uniqueId:         String?
    
    init(dataToSend:        Data?,
         fileExtension:     String?,
         fileName:          String?,
         fileSize:          Int64?,
         mimeType:          String?,
         originalFileName:  String?,
         threadId:          Int?,
         xC:                Int?,
         yC:                Int?,
         hC:                Int?,
         wC:                Int?,
         typeCode:          String?,
         uniqueId:          String?) {
        
        self.dataToSend         = dataToSend
        self.fileExtension      = fileExtension
        self.fileName           = fileName
        self.fileSize           = fileSize
        self.mimeType           = mimeType ?? ""
        self.originalFileName   = originalFileName
        self.threadId           = threadId
        self.xC                 = xC
        self.yC                 = yC
        self.hC                 = hC
        self.wC                 = wC
        self.typeCode           = typeCode
        self.uniqueId           = uniqueId
    }
    
    init(imageInputModel: UploadImageRequestModel) {
        self.dataToSend         = imageInputModel.dataToSend
        self.fileExtension      = imageInputModel.fileExtension
        self.fileName           = imageInputModel.fileName
        self.fileSize           = imageInputModel.fileSize
        self.mimeType           = imageInputModel.mimeType
        self.originalFileName   = imageInputModel.originalFileName
        self.threadId           = imageInputModel.threadId
        self.xC                 = imageInputModel.xC
        self.yC                 = imageInputModel.yC
        self.hC                 = imageInputModel.hC
        self.wC                 = imageInputModel.wC
        self.typeCode           = imageInputModel.typeCode
        self.uniqueId           = imageInputModel.uniqueId
    }
    
    
    public func returnDataAsJSONAndData() -> (jsonResult: JSON, imageToSend: Data?) {
        let result: JSON = ["fileExtension":    fileExtension ?? NSNull(),
                            "fileName":         fileName ?? NSNull(),
                            "fileSize":         fileSize ?? NSNull(),
                            "mimeType":         mimeType,
                            "originalFileName": originalFileName ?? NSNull(),
                            "threadId":         threadId ?? NSNull(),
                            "xC":               xC ?? NSNull(),
                            "yC":               yC ?? NSNull(),
                            "hC":               hC ?? NSNull(),
                            "wC":               wC ?? NSNull(),
                            "typeCode":         typeCode ?? NSNull(),
                            "uniqueId":         uniqueId ?? NSNull()]
        return (result, dataToSend)
    }
    
}
