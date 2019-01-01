//
//  GetFileRequestModel.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 10/10/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation

open class GetFileRequestModel {
    
    public let downloadable:    Bool?
    public let fileId:          Int
    public let hashCode:        String
    
    public init(downloadable:   Bool?,
                fileId:         Int,
                hashCode:       String) {
        
        self.fileId         = fileId
        self.downloadable   = downloadable
        self.hashCode       = hashCode
    }
    
}


