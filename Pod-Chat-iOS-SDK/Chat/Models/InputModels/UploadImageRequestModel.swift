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
    public let fileName:            String
    public let fileSize:            Int64
    public let originalFileName:    String
    public let threadId:            Int?
    public let xC:                  Int?
    public let yC:                  Int?
    public let hC:                  Int?
    public let wC:                  Int?
    
    public let typeCode:            String?
    public let uniqueId:            String
    
    public init(dataToSend:         Data,
                fileExtension:      String?,
                fileName:           String?,
                originalFileName:   String?,
                threadId:           Int?,
                xC:                 Int?,
                yC:                 Int?,
                hC:                 Int?,
                wC:                 Int?,
                typeCode:           String?,
                uniqueId:           String?) {
        
        let theFileName:           String  = fileName ?? "\(NSUUID().uuidString))"
        
        self.dataToSend         = dataToSend
        self.fileExtension      = fileExtension
        self.fileName           = theFileName
        self.fileSize           = Int64(dataToSend.count)
        self.originalFileName   = originalFileName ?? theFileName
        self.threadId           = threadId
        self.xC                 = xC
        self.yC                 = yC
        self.hC                 = hC
        self.wC                 = wC
        self.typeCode           = typeCode
        self.uniqueId           = uniqueId ?? NSUUID().uuidString
    }
    
    func convertContentToParameters() -> Parameters {
        
        var content: Parameters = [:]
        content["fileName"]         = JSON(self.fileName)
        content["uniqueId"]         = JSON(self.uniqueId)
        content["fileSize"]         = JSON(self.fileSize)
        content["originalFileName"] = JSON(self.originalFileName)
        content["threadId"]         = JSON(self.threadId ?? 0)
        
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

