//
//  MapStaticImageRequestModel.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 10/12/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation


open class MapStaticImageRequestModel {
    
    public let centerLat:   Double
    public let centerLng:   Double
    public let height:      Int
    public let type:        String
    public let width:       Int
    public let zoom:        Int
    
    public init(centerLat:  Double,
                centerLng:  Double,
                height:     Int?,
                type:       String?,
                width:      Int?,
                zoom:       Int?) {
        
        self.centerLat  = centerLat
        self.centerLng  = centerLng
        self.height     = height ?? 500
        self.type       = type ?? "standard-night"
        self.width      = width ?? 800
        self.zoom       = zoom ?? 15
    }
    
}



