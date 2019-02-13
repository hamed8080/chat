//
//  UploadFileRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation

open class UploadFileRequestModel {
    
    public let dataToSend:          Data
    public let fileExtension:       String?
    public let fileName:            String?
    public let fileSize:            Int?
    public let originalFileName:    String?
    public let threadId:            Int?
    public let uniqueId:            String?
    
    public init(dataToSend:        Data,
                fileExtension:     String?,
                fileName:          String,
                fileSize:          Int?,
                originalFileName:  String?,
                threadId:          Int?,
                uniqueId:          String?) {
        
        self.dataToSend         = dataToSend
        self.fileExtension      = fileExtension
        self.fileName           = fileName
        self.fileSize           = fileSize
        self.originalFileName   = originalFileName
        self.threadId           = threadId
        self.uniqueId           = uniqueId
    }
    
}

