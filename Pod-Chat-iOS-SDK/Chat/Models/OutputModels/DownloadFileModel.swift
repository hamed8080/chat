//
//  DownloadFileModel.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 9/24/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


open class DownloadFileModel {
    /*
     ---------------------------------------
     * responseAsJSON:
     *  - hasError          Bool
     *  - errorMessage      String
     *  - errorCode         Int
     *  + result            DownloadFileModel:
     *      + DownloadFile    DownloadFileAsJSON
     *          - hashCode      String
     *          - id            Int
     *          - name          String
     ---------------------------------------
     * responseAsModel:
     *  - hasError          Bool
     *  - errorMessage      String
     *  - errorCode         Int
     *  + user              User
     ---------------------------------------
     */
    
    // downloadFile model properties
    public let errorCode:           Int
    public let errorMessage:        String
    public let hasError:            Bool
    public let downloadFile:        FileObject?
    
    public var uploadFileJSON: JSON = [:]
    
    public init(messageContentJSON: JSON?,
                errorCode:      Int,
                errorMessage:   String,
                hasError:       Bool) {
        
        self.hasError           = hasError
        self.errorMessage       = errorMessage
        self.errorCode          = errorCode
        
        if let myFile = messageContentJSON {
            self.downloadFile = FileObject(messageContent: myFile)
        } else {
            self.downloadFile = nil
        }
        
    }
    
    public init(messageContentModel: FileObject?,
                errorCode:      Int,
                errorMessage:   String,
                hasError:       Bool) {
        
        self.hasError           = hasError
        self.errorMessage       = errorMessage
        self.errorCode          = errorCode
        
        if let myFile = messageContentModel {
            self.downloadFile = myFile
        } else {
            self.downloadFile = nil
        }
        
    }
    
    
    public func returnDataAsJSON() -> JSON {
        let result: JSON = ["downloadFile":   downloadFile?.formatToJSON() ?? NSNull()]
        
        let resultAsJSON: JSON = ["result":     result,
                                  "errorCode":  errorCode,
                                  "errorMessage": errorMessage,
                                  "hasError":   hasError]
        
        return resultAsJSON
    }
    
}
