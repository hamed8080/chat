//
//  GetFileRequest.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 10/10/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Alamofire
import SwiftyJSON

open class GetFileRequest {
    
    public let downloadable:    Bool?
    public let fileId:          Int
    public let hashCode:        String
    public let serverResponse:  Bool
    
    public init(downloadable:   Bool?,
                fileId:         Int,
                hashCode:       String,
                serverResponse: Bool?) {
        
        self.fileId         = fileId
        self.downloadable   = downloadable
        self.hashCode       = hashCode
        self.serverResponse = serverResponse ?? false
    }
    
    func convertContentToParameters() -> Parameters {
        var parameters: Parameters = ["hashCode":   self.hashCode,
                                      "fileId":     self.fileId]
        if let theDownloadable = self.downloadable {
            parameters["downloadable"] = JSON(theDownloadable)
        }
        return parameters
    }
    
}


open class GetFileRequestModel: GetFileRequest {
    
}


