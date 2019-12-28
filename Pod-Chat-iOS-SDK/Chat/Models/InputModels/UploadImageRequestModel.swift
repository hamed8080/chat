//
//  UploadImageRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Alamofire
import SwiftyJSON

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
    
    public let typeCode:            String?
    public let uniqueId:            String
    
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
                typeCode:           String?,
                uniqueId:           String?) {
        
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
        self.typeCode           = typeCode
        self.uniqueId           = uniqueId ?? NSUUID().uuidString
    }
    
    func convertContentToParameters() -> Parameters {
        
//        var fileName:           String  = ""
//        var fileType:           String  = ""
//        var fileSize:           Int     = 0
//        var theFileExtension:       String  = ""
        
        var content: Parameters = [:]
        content["fileName"] = JSON(self.fileName ?? "\(NSUUID().uuidString))")
        content["uniqueId"] = JSON(self.uniqueId)
        if let myFileSize_ = self.fileSize {
            content["fileSize"] = JSON(myFileSize_)
        }
        if let threadId_ = self.threadId {
            content["threadId"] = JSON(threadId_)
        }
        if let myOriginalFileName_ = self.originalFileName {
            content["originalFileName"] = JSON(myOriginalFileName_)
        }
        if let xC_ = self.xC {
            content["xC"] = JSON(xC_)
        }
        if let yC_ = self.yC {
            content["yC"] = JSON(yC_)
        }
        if let hC_ = self.hC {
            content["hC"] = JSON(hC_)
        }
        if let wC_ = self.wC {
            content["wC"] = JSON(wC_)
        }

        return content
    }
    
}

