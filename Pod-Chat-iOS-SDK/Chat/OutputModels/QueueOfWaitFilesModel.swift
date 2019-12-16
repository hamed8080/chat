//
//  QueueOfWaitFilesModel.swift
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
    let fileSize:           Int?
    let originalFileName:   String?
    let threadId:           Int?
    let uniqueId:           String?
    
    init(dataToSend:        Data?,
         fileExtension:     String?,
         fileName:          String?,
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
    
    init(fileInputModel: UploadFileRequestModel) {
        self.dataToSend         = fileInputModel.dataToSend
        self.fileExtension      = fileInputModel.fileExtension
        self.fileName           = fileInputModel.fileName
        self.fileSize           = fileInputModel.fileSize
        self.originalFileName   = fileInputModel.originalFileName
        self.threadId           = fileInputModel.threadId
        self.uniqueId           = fileInputModel.uniqueId
    }
    
}


