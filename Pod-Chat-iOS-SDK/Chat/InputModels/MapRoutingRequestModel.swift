//
//  MapRoutingModel.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 10/11/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation

open class MapRoutingRequestModel {
    
    public let originLat:       Double
    public let originLng:       Double
    public let destinationLat:  Double
    public let destinationLng:  Double
    public let alternative:     Bool
    
    public init(originLat:      Double,
                originLng:      Double,
                destinationLat: Double,
                destinationLng: Double,
                alternative:    Bool?) {
        
        self.originLat      = originLat
        self.originLng      = originLng
        self.destinationLat = destinationLat
        self.destinationLng = destinationLng
        if let alter = alternative {
            self.alternative = alter
        } else {
            self.alternative = true
        }
        
    }
    
}

