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
    public let height:          Int?
    public let hashCode:        String
    public let imageId:         Int
    public let width:           Int?
    
    
    public init(actual:         Bool?,
                downloadable:   Bool?,
                height:         Int?,
                hashCode:       String,
                imageId:        Int,
                width:          Int?) {
        
        self.actual         = actual
        self.downloadable   = downloadable
        self.height         = height
        self.hashCode       = hashCode
        self.imageId        = imageId
        self.width          = width
    }
    
}


