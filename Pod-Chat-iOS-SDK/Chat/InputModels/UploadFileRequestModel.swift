//
//  UploadFileRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Alamofire
import SwiftyJSON

open class UploadFileRequestModel {
    
    public let dataToSend:          Data
    public let fileExtension:       String?
    public let fileName:            String?
    public let fileSize:            Int?
    public let originalFileName:    String?
    public let threadId:            Int?
    
    public let typeCode:            String?
    public let uniqueId:            String
    
    public init(dataToSend:         Data,
                fileExtension:      String?,
                fileName:           String,
                fileSize:           Int?,
                originalFileName:   String?,
                threadId:           Int?,
                typeCode:           String?,
                uniqueId:           String?) {
        
        self.dataToSend         = dataToSend
        self.fileExtension      = fileExtension
        self.fileName           = fileName
        self.fileSize           = fileSize
        self.originalFileName   = originalFileName
        self.threadId           = threadId
        self.typeCode           = typeCode
        self.uniqueId           = uniqueId ?? NSUUID().uuidString
    }
    
    
    func convertContentToParameters() -> Parameters {
        
        var content: Parameters = [:]
        let theFileName = JSON(self.fileName ?? "\(NSUUID().uuidString))")
        content["fileName"] = JSON(theFileName)
        content["uniqueId"] = JSON(self.uniqueId)
        content["originalFileName"] = JSON(self.originalFileName ?? theFileName)
        if let myFileSize_ = self.fileSize {
            content["fileSize"] = JSON(myFileSize_)
        }
        if let threadId_ = self.threadId {
            content["threadId"] = JSON(threadId_)
        }

        return content
    }
    
}

