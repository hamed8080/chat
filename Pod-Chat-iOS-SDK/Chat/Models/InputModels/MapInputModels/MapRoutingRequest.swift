//
//  MapRoutingRequest.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 10/11/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation

@available(*,deprecated , message:"Removed in 0.10.5.0 version.")
open class MapRoutingRequest {
    
    public let alternative:     Bool
    public let destination:     (lat: Double, lng: Double)
    public let origin:          (lat: Double, lng: Double)
    
    public init(alternative:    Bool?,
                destination:    (Double, Double),
                origin:         (Double, Double)) {
        
        if let alter = alternative {
            self.alternative = alter
        } else {
            self.alternative = true
        }
        self.destination    = destination
        self.origin         = origin
    }
    
    public init(alternative:    Bool?,
                destinationLat: Double,
                destinationLng: Double,
                originLat:      Double,
                originLng:      Double) {
        
        if let alter = alternative {
            self.alternative = alter
        } else {
            self.alternative = true
        }
        self.destination = (destinationLat, destinationLng)
        self.origin      = (originLat, originLng)
    }
    
}

@available(*,deprecated , message:"Removed in 0.10.5.0 version.")
open class MapRoutingRequestModel: MapRoutingRequest {
    
}

