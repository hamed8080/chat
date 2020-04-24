//
//  UploadImageRequest.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Alamofire
import SwiftyJSON

open class UploadImageRequest: UploadRequest {
    
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


open class UploadImageRequestModel: UploadImageRequest {
    
}


