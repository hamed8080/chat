//
//  MapStaticImageRequestModel.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 10/12/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation


open class MapStaticImageRequestModel {
    
    public let type:        String
    public let zoom:        Int
    public let centerLat:   Double
    public let centerLng:   Double
    public let width:       Int
    public let height:      Int
    
    public init(type:       String?,
                zoom:       Int?,
                centerLat:  Double,
                centerLng:  Double,
                width:      Int?,
                height:     Int?) {
        
        self.type       = type ?? "standard-night"
        self.zoom       = zoom ?? 15
        self.centerLat  = centerLat
        self.centerLng  = centerLng
        self.width      = width ?? 800
        self.height     = height ?? 500
    }
    
}



