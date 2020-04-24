//
//  UploadFileResponse.swift
//  Chat
//
//  Created by Mahyar Zhiani on 8/5/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class UploadFileModel: ResponseModel, ResponseModelDelegates {
    
    public let uploadFile:  FileObject?
    
    public init(messageContentJSON: JSON?,
                errorCode:          Int,
                errorMessage:       String,
                hasError:           Bool/*,
         localPath:      String?*/) {
        
        //        if let pathString = localPath {
        //            self.localPath = pathString
        //        }
        
        if let myFile = messageContentJSON {
            self.uploadFile = FileObject(messageContent: myFile)
        } else {
            self.uploadFile = nil
        }
        super.init(hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
    }
    
    public init(messageContentModel:    FileObject?,
                errorCode:              Int,
                errorMessage:           String,
                hasError:               Bool/*,
         localPath:      String?*/) {
        
        //        if let pathString = localPath {
        //            self.localPath = pathString
        //        }
        
        if let myFile = messageContentModel {
            self.uploadFile = myFile
        } else {
            self.uploadFile = nil
        }
        super.init(hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
    }
    
    
    public func returnDataAsJSON() -> JSON {
        let result: JSON = ["uploadFile":   uploadFile?.formatToJSON() ?? NSNull()]
        
        let resultAsJSON: JSON = ["result":         result,
                                  "errorCode":      errorCode,
                                  "errorMessage":   errorMessage,
                                  "hasError":       hasError/*,
             "localPath": localPath*/]
        
        return resultAsJSON
    }
    
    
    func returnMetaData(onServiceAddress: String) -> JSON {
        var fileMetadata : JSON = [:]
        
        if let upload = uploadFile {
            let link = "\(onServiceAddress)\(SERVICES_PATH.GET_FILE.rawValue)?fileId=\(upload.id)&hashCode=\(upload.hashCode)"
            fileMetadata["link"]        = JSON(link)
            fileMetadata["id"]          = JSON(upload.id)
            fileMetadata["name"]        = JSON(upload.name ?? "")
            fileMetadata["hashCode"]    = JSON(upload.hashCode)
        }
        
        return fileMetadata
    }
    
}


open class UploadFileResponse: UploadFileModel {
    
}

