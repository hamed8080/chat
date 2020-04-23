//
//  DownloadFileResponse.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 9/24/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


open class DownloadFileResponse: ResponseModel, ResponseModelDelegates {
    
    public let downloadFile:    FileObject?
    
    public init(messageContentJSON: JSON?,
                errorCode:          Int,
                errorMessage:       String,
                hasError:           Bool) {
        
        if let myFile = messageContentJSON {
            self.downloadFile = FileObject(messageContent: myFile)
        } else {
            self.downloadFile = nil
        }
        super.init(hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
    }
    
    public init(messageContentModel:    FileObject?,
                errorCode:              Int,
                errorMessage:           String,
                hasError:               Bool) {
        
        if let myFile = messageContentModel {
            self.downloadFile = myFile
        } else {
            self.downloadFile = nil
        }
        super.init(hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
    }
    
    
    public func returnDataAsJSON() -> JSON {
        let result: JSON = ["downloadFile": downloadFile?.formatToJSON() ?? NSNull()]
        
        let resultAsJSON: JSON = ["result":         result,
                                  "errorCode":      errorCode,
                                  "errorMessage":   errorMessage,
                                  "hasError":       hasError]
        
        return resultAsJSON
    }
    
}


open class DownloadFileModel: DownloadFileResponse {
    
}

