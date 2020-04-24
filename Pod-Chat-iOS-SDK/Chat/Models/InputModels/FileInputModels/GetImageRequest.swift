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
    
    public let actual:          Bool?
    public let downloadable:    Bool?
    public let height:          Int?
    public let hashCode:        String
    public let imageId:         Int
    public let width:           Int?
    public let serverResponse:  Bool
    
    public init(actual:         Bool?,
                downloadable:   Bool?,
                height:         Int?,
                hashCode:       String,
                imageId:        Int,
                width:          Int?,
                serverResponse: Bool?) {
        
        self.actual         = actual
        self.downloadable   = downloadable
        self.height         = height
        self.hashCode       = hashCode
        self.imageId        = imageId
        self.width          = width
        self.serverResponse = serverResponse ?? false
    }
    
    
    func convertContentToParameters() -> Parameters {
        var parameters: Parameters = ["hashCode": self.hashCode,
                                      "imageId": self.imageId]
        if let theActual = self.actual {
            parameters["actual"] = JSON(theActual)
        }
        if let theDownloadable = self.downloadable {
            parameters["downloadable"] = JSON(theDownloadable)
        }
        if let theHeight = self.height {
            parameters["height"] = JSON(theHeight)
        }
        if let theWidth = self.width {
            parameters["width"] = JSON(theWidth)
        }
        return parameters
    }
    
}


open class GetImageRequestModel: GetImageRequest {
    
}


