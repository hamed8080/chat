//
//  GetImageRequest.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 10/10/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Alamofire
import SwiftyJSON

open class GetImageRequest {
    
    public let imageId:         Int
    public let hashCode:        String
    public let quality:         Float?
    public let size:            String?
    public let crop:            Bool?
    public let serverResponse:  Bool
    
    public init(imageId:        Int,
                hashCode:       String,
                quality:        Float?,
                crop:           Bool?,
                size:           String?,
                serverResponse: Bool?) {
        
        self.imageId        = imageId
        self.hashCode       = hashCode
        self.quality        = quality
        self.size           = size
        self.crop           = crop
        self.serverResponse = serverResponse ?? false
    }
    
    
    func convertContentToParameters() -> Parameters {
        var parameters: Parameters = [:]
        parameters["hash"] = self.hashCode
        parameters[" "] = UUID().uuidString
        
        if let size_ = self.size {
            parameters["size"] = JSON(size_)
        }
        if let quality_ = self.quality {
            parameters["quality"] = JSON(quality_)
        }
        if let crop_ = self.crop {
            parameters["crop"] = JSON(crop_)
        }
        
        return parameters
    }
    
}


open class GetImageRequestModel: GetImageRequest {
    
}


