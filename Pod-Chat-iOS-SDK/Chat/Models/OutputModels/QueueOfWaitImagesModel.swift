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
    let fileSize:         Int?
    let originalFileName: String?
    let threadId:         Int?
    let uniqueId:         String?
    let xC:               Int?
    let yC:               Int?
    let hC:               Int?
    let wC:               Int?
    
    init(dataToSend:        Data?,
         fileExtension:     String?,
         fileName:          String?,
         fileSize:          Int?,
         originalFileName:  String?,
         threadId:          Int?,
         uniqueId:          String?,
         xC:                Int?,
         yC:                Int?,
         hC:                Int?,
         wC:                Int?) {
        
        self.dataToSend         = dataToSend
        self.fileExtension      = fileExtension
        self.fileName           = fileName
        self.fileSize           = fileSize
        self.originalFileName   = originalFileName
        self.threadId           = threadId
        self.uniqueId           = uniqueId
        self.xC                 = xC
        self.yC                 = yC
        self.hC                 = hC
        self.wC                 = wC
        
    }
    
    init(imageInputModel: UploadImageRequestModel) {
        self.dataToSend         = imageInputModel.dataToSend
        self.fileExtension      = imageInputModel.fileExtension
        self.fileName           = imageInputModel.fileName
        self.fileSize           = imageInputModel.fileSize
        self.originalFileName   = imageInputModel.originalFileName
        self.threadId           = imageInputModel.threadId
        self.uniqueId           = imageInputModel.uniqueId
        self.xC                 = imageInputModel.xC
        self.yC                 = imageInputModel.yC
        self.hC                 = imageInputModel.hC
        self.wC                 = imageInputModel.wC
    }
    
}
