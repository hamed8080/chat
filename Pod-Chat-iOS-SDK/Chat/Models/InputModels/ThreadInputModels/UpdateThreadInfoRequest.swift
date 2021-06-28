//
//  UpdateThreadInfoRequest.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import FanapPodAsyncSDK
import SwiftyJSON

@available(*,deprecated , message:"Removed in 0.10.5.0 version.")
open class UpdateThreadInfoRequest: RequestModelDelegates {
    
    public let description:     String? // Description for thread
//    public let image:           String? // URL og thread image to be set
    public var metadata:        String? // New Metadata to be set on thread
    public var threadImage:     UploadImageRequest?
    public let threadId:        Int     // Id of thread
    public let title:           String? // New Title for thread
    
    public let typeCode:        String?
    public let uniqueId:        String
    
    public init(description:        String?,
//                image:              String?,
                metadata:           String?,
                threadId:           Int,
                threadImage:        UploadImageRequest?,
                title:              String,
                typeCode:           String?,
                uniqueId:           String?) {
        
        self.description    = description
//        self.image          = image
        self.metadata       = metadata
        self.threadId       = threadId
        self.threadImage    = threadImage
        self.title          = title
        
        self.typeCode       = typeCode
        self.uniqueId       = uniqueId ?? UUID().uuidString
    }
    
    public func convertContentToJSON() -> JSON {
        var content: JSON = [:]
//        if let image_ = self.image {
//            content["image"] = JSON(image_)
//        }
        if let description_ = self.description {
            let theDecription = MakeCustomTextToSend(message: description_).replaceSpaceEnterWithSpecificCharecters()
            content["description"] = JSON(theDecription)
        }
        if let name_ = self.title {
            let theName = MakeCustomTextToSend(message: name_).replaceSpaceEnterWithSpecificCharecters()
            content["name"] = JSON(theName)
        }
        if let metadata_ = self.metadata {
            let metadataStr = MakeCustomTextToSend(message: metadata_).replaceSpaceEnterWithSpecificCharecters()
            content["metadata"] = JSON(metadataStr)
        }
        
        return content
    }
    
    public func convertContentToJSONArray() -> [JSON] {
        return []
    }
    
}

@available(*,deprecated , message:"Removed in 0.10.5.0 version.")
open class UpdateThreadInfoRequestModel: UpdateThreadInfoRequest {
    
}

