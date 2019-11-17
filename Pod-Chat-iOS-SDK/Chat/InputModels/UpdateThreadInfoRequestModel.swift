//
//  UpdateThreadInfoRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation

import SwiftyJSON


open class UpdateThreadInfoRequestModel {
    
    public let description:     String?
    public let image:           String?
    public let metadata:        JSON?
    public let threadId:        Int
    public let title:           String?
    
    public let requestTypeCode: String?
    public let requestUniqueId: String?
    
    public init(description:        String?,
                image:              String?,
                metadata:           JSON?,
                threadId:           Int,
                title:              String,
                requestTypeCode:    String?,
                requestUniqueId:    String?) {
        
        self.description        = description
        self.image              = image
        self.metadata           = metadata
        self.threadId           = threadId
        self.title              = title
        self.requestTypeCode    = requestTypeCode
        self.requestUniqueId    = requestUniqueId
    }
    
    func convertContentToJSON() -> JSON {
        var content: JSON = [:]
        if let image = self.image {
            content["image"] = JSON(image)
        }
        if let description = self.description {
            content["description"] = JSON(description)
        }
        if let name = self.title {
            content["name"] = JSON(name)
        }
        if let metadata = self.metadata {
            let metadataStr = "\(metadata)"
            content["metadata"] = JSON(metadataStr)
        }
        if let title = self.title {
            content["title"] = JSON(title)
        }
        
        return content
    }
    
}

