//
//  MapRoutingModel.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 10/11/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation

open class MapRoutingRequestModel {
    
    public let alternative:     Bool
    public let destinationLat:  Double
    public let destinationLng:  Double
    public let originLat:       Double
    public let originLng:       Double
    
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
        self.destinationLat = destinationLat
        self.destinationLng = destinationLng
        self.originLat      = originLat
        self.originLng      = originLng
    }
    
}

