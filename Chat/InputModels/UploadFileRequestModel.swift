//
//  UploadFileRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation

open class UploadFileRequestModel {
    
    public let fileExtension:       String?
    public let fileName:            String?
    public let fileSize:            Int?
    public let threadId:            Int?
    public let uniqueId:            String?
    public let originalFileName:    String?
    public let dataToSend:          Data
    
    init(fileExtension:     String?,
         fileName:          String,
         fileSize:          Int?,
         threadId:          Int,
         uniqueId:          String?,
         originalFileName:  String?,
         dataToSend:        Data) {
        
        self.fileExtension      = fileExtension
        self.fileName           = fileName
        self.fileSize           = fileSize
        self.threadId           = threadId
        self.uniqueId           = uniqueId
        self.originalFileName   = originalFileName
        self.dataToSend         = dataToSend
    }
    
}

