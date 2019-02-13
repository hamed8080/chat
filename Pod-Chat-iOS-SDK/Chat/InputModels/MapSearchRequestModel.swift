//
//  MapSearchRequestModel.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 10/11/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation

open class MapSearchRequestModel {
    
    public let lat:     Double
    public let lng:     Double
    public let term:    String
    
    public init(lat:    Double,
                lng:    Double,
                term:   String) {
        
        self.lat    = lat
        self.lng    = lng
        self.term   = term
    }
    
}


