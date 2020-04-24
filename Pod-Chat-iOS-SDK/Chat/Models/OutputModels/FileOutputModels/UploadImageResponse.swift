//
//  UploadImageResponse.swift
//  Chat
//
//  Created by Mahyar Zhiani on 8/5/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class UploadImageModel: ResponseModel, ResponseModelDelegates {
    
    //    public var localPath:           String = ""
    public let uploadImage:     ImageObject?
    
    public init(messageContentJSON: JSON?,
                errorCode:      Int,
                errorMessage:   String,
                hasError:       Bool/*,
         localPath:      String?*/) {
        
        //        if let pathString = localPath {
        //            self.localPath = pathString
        //        }
        
        if let content = messageContentJSON {
            self.uploadImage = ImageObject(messageContent: content)
        } else {
            uploadImage = nil
        }
        super.init(hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
    }
    
    public init(messageContentModel: ImageObject?,
                errorCode:      Int,
                errorMessage:   String,
                hasError:       Bool/*,
         localPath:      String?*/) {
        
        //        if let pathString = localPath {
        //            self.localPath = pathString
        //        }
        
        if let myImage = messageContentModel {
            self.uploadImage    = myImage
        } else {
            uploadImage = nil
        }
        super.init(hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
    }
    
    
    public func returnDataAsJSON() -> JSON {
        let result: JSON = ["uploadImage":  uploadImage?.formatToJSON() ?? NSNull()]
        
        let resultAsJSON: JSON = ["result":         result,
                                  "errorCode":      errorCode,
                                  "errorMessage":   errorMessage,
                                  "hasError":       hasError/*,
             "localPath": localPath*/]
        
        return resultAsJSON
    }
    
    
    func returnMetaData(onServiceAddress: String) -> JSON {
        var imageMetadata : JSON = [:]
        
        if let upload = uploadImage {
            let link = "\(onServiceAddress)\(SERVICES_PATH.GET_IMAGE.rawValue)?imageId=\(upload.id)&hashCode=\(upload.hashCode)"
            imageMetadata["link"]            = JSON(link)
            imageMetadata["id"]              = JSON(upload.id)
            imageMetadata["name"]            = JSON(upload.name ?? "")
            imageMetadata["height"]          = JSON(upload.height ?? 0)
            imageMetadata["width"]           = JSON(upload.width ?? 0)
            imageMetadata["actualHeight"]    = JSON(upload.actualHeight ?? 0)
            imageMetadata["actualWidth"]     = JSON(upload.actualWidth ?? 0)
            imageMetadata["hashCode"]        = JSON(upload.hashCode)
        }
        
        return imageMetadata
    }
    
}


open class UploadImageResponse: UploadImageModel {
    
}

