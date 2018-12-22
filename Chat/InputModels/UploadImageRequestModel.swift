//
//  UploadImageRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation

open class UploadImageRequestModel {
    
    public let fileExtension:       String?
    public let fileName:            String?
    public let fileSize:            Int?
    public let threadId:            Int?
    public let uniqueId:            String?
    public let originalFileName:    String?
    public let xC:                  Int?
    public let yC:                  Int?
    public let hC:                  Int?
    public let wC:                  Int?
    public let dataToSend:          Data
    
    init(fileExtension:     String?,
         fileName:          String,
         fileSize:          Int?,
         threadId:          Int,
         uniqueId:          String?,
         originalFileName:  String?,
         xC:                Int?,
         yC:                Int?,
         hC:                Int?,
         wC:                Int?,
         dataToSend:        Data) {
        
        self.fileExtension      = fileExtension
        self.fileName           = fileName
        self.fileSize           = fileSize
        self.threadId           = threadId
        self.uniqueId           = uniqueId
        self.originalFileName   = originalFileName
        self.xC                 = xC
        self.yC                 = yC
        self.hC                 = hC
        self.wC                 = wC
        self.dataToSend         = dataToSend
    }
    
}

