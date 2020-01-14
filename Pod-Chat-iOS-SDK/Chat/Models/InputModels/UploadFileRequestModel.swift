//
//  UploadFileRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Alamofire
import SwiftyJSON

open class UploadFileRequestModel: UploadRequestModel {
    
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

