//
//  UploadImageRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation

open class UploadImageRequestModel {
    
    public let dataToSend:          Data
    public let fileExtension:       String?
    public let fileName:            String?
    public let fileSize:            Int?
    public let originalFileName:    String?
    public let threadId:            Int?
    public let xC:                  Int?
    public let yC:                  Int?
    public let hC:                  Int?
    public let wC:                  Int?
    public let requestUniqueId:     String?
    
    public init(dataToSend:         Data,
                fileExtension:      String?,
                fileName:           String,
                fileSize:           Int?,
                originalFileName:   String?,
                threadId:           Int?,
                xC:                 Int?,
                yC:                 Int?,
                hC:                 Int?,
                wC:                 Int?,
                requestUniqueId:    String?) {
        
        self.dataToSend         = dataToSend
        self.fileExtension      = fileExtension
        self.fileName           = fileName
        self.fileSize           = fileSize
        self.originalFileName   = originalFileName
        self.threadId           = threadId
        self.xC                 = xC
        self.yC                 = yC
        self.hC                 = hC
        self.wC                 = wC
        self.requestUniqueId    = requestUniqueId
    }
    
}

