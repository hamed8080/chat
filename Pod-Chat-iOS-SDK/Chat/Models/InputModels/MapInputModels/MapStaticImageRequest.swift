//
//  MapStaticImageRequest.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 10/12/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation

@available(*,deprecated , message:"Removed in 0.10.5.0 version.")
open class MapStaticImageRequest {
    
    public let center:  (lat: Double, lng: Double)
    public let height:  Int
    public let type:    String
    public let width:   Int
    public let zoom:    Int
    
    public init(center: (Double, Double),
                height: Int?,
                type:   String?,
                width:  Int?,
                zoom:   Int?) {
        
        self.center = center
        self.height = height ?? 500
        self.type   = type ?? "standard-night"
        self.width  = width ?? 800
        self.zoom   = zoom ?? 15
    }
    
    public init(centerLat:  Double,
                centerLng:  Double,
                height:     Int?,
                type:       String?,
                width:      Int?,
                zoom:       Int?) {
        
        self.center = (centerLat, centerLng)
        self.height = height ?? 500
        self.type   = type ?? "standard-night"
        self.width  = width ?? 800
        self.zoom   = zoom ?? 15
    }
    
}

@available(*,deprecated , message:"Removed in 0.10.5.0 version.")
open class MapStaticImageRequestModel: MapStaticImageRequest {
    
}



