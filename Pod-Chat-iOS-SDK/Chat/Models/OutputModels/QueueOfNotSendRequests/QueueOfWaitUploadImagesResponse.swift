//
//  QueueOfWaitUploadImagesResponse.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 11/28/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class QueueOfWaitUploadImagesModel {
    
    let dataToSend:     Data?
    let fileExtension:  String?
    let fileName:       String?
    let fileSize:       Int64?
    let isPublic:       Bool?
    let mimeType:       String?
    let originalName:   String?
    let userGroupHash:  String?
    let xC:             Int
    let yC:             Int
    let hC:             Int
    let wC:             Int
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
         xC:            Int,
         yC:            Int,
         hC:            Int,
         wC:            Int,
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
        self.xC             = xC
        self.yC             = yC
        self.hC             = hC
        self.wC             = wC
        self.typeCode       = typeCode
        self.uniqueId       = uniqueId
    }
    
    init(imageInputModel: UploadImageRequestModel) {
        self.dataToSend     = imageInputModel.dataToSend
        self.fileExtension  = imageInputModel.fileExtension
        self.fileName       = imageInputModel.fileName
        self.fileSize       = imageInputModel.fileSize
        self.isPublic       = imageInputModel.isPublic
        self.mimeType       = imageInputModel.mimeType
        self.originalName   = imageInputModel.originalName
        self.userGroupHash  = imageInputModel.userGroupHash
        self.xC             = imageInputModel.xC
        self.yC             = imageInputModel.yC
        self.hC             = imageInputModel.hC
        self.wC             = imageInputModel.wC
        self.typeCode       = imageInputModel.typeCode
        self.uniqueId       = imageInputModel.uniqueId
    }
    
    
    public func returnDataAsJSONAndData() -> (jsonResult: JSON, imageToSend: Data?) {
        let result: JSON = ["fileExtension":    fileExtension ?? NSNull(),
                            "fileName":         fileName ?? NSNull(),
                            "fileSize":         fileSize ?? NSNull(),
                            "isPublic":         isPublic ?? NSNull(),
                            "mimeType":         mimeType ?? "",
                            "originalName":     originalName ?? NSNull(),
                            "userGroupHash":    userGroupHash ?? NSNull(),
                            "xC":               xC,
                            "yC":               yC,
                            "hC":               hC,
                            "wC":               wC,
                            "typeCode":         typeCode ?? NSNull(),
                            "uniqueId":         uniqueId ?? NSNull()]
        return (result, dataToSend)
    }
    
}


open class QueueOfWaitUploadImagesResponse: QueueOfWaitUploadImagesModel {
    
}


