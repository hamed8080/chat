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
    public let fileName:            String
    public let fileSize:            Int64
    public let originalFileName:    String
    public let threadId:            Int?
    
    public let typeCode:            String?
    public let uniqueId:            String
    
    public init(dataToSend:         Data,
                fileExtension:      String?,
                fileName:           String?,
                originalFileName:   String?,
                threadId:           Int?,
                typeCode:           String?,
                uniqueId:           String?) {
        
        let theFileName = fileName ?? "\(NSUUID().uuidString))"
        
        self.dataToSend         = dataToSend
        self.fileExtension      = fileExtension
        self.fileName           = theFileName
        self.fileSize           = Int64(dataToSend.count)
        self.originalFileName   = originalFileName ?? theFileName
        self.threadId           = threadId
        self.typeCode           = typeCode
        self.uniqueId           = uniqueId ?? NSUUID().uuidString
    }
    
    
    func convertContentToParameters() -> Parameters {
        
        var content: Parameters = [:]
        
        content["fileName"]         = JSON(self.fileName)
        content["uniqueId"]         = JSON(self.uniqueId)
        content["originalFileName"] = JSON(self.originalFileName)
        content["fileSize"]         = JSON(self.fileSize)
        content["threadId"]         = JSON(self.threadId ?? 0)
        
        return content
    }
    
}

