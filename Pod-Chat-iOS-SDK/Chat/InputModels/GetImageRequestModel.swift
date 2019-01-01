//
//  GetImageRequestModel.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 10/10/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation

open class GetImageRequestModel {
    
    public let actual:          Bool?
    public let downloadable:    Bool?
    public let hashCode:        String
    public let height:          Int?
    public let imageId:         Int
    public let width:           Int?
    
    
    public init(actual:         Bool?,
                downloadable:   Bool?,
                hashCode:       String,
                height:         Int?,
                imageId:        Int,
                width:          Int?) {
        
        self.imageId        = imageId
        self.width          = width
        self.height         = height
        self.actual         = actual
        self.downloadable   = downloadable
        self.hashCode       = hashCode
    }
    
}


