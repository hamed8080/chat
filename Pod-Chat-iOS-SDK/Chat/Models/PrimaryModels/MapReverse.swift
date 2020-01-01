//
//  MapReverse.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 10/11/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


open class MapReverse {
    
    public var address:             String?
    public var city:                String?
    public var neighbourhood:       Bool?
    public var in_odd_even_zone:    Bool?
    public var in_traffic_zone:     Bool?
    public var municipality_zone:   Int?
    public var state:               String?
    
    public init(messageContent: JSON) {
        self.address            = messageContent["address"].string
        self.city               = messageContent["city"].string
        self.neighbourhood      = messageContent["neighbourhood"].bool
        self.in_odd_even_zone   = messageContent["in_odd_even_zone"].bool
        self.in_traffic_zone    = messageContent["in_traffic_zone"].bool
        self.municipality_zone  = messageContent["municipality_zone"].int
        self.state              = messageContent["state"].string
    }
    
    public init(address:            String?,
                city:               String?,
                neighbourhood:      Bool?,
                in_odd_even_zone:   Bool?,
                in_traffic_zone:    Bool?,
                municipality_zone:  Int?,
                state:              String?) {
        
        self.address            = address
        self.city               = city
        self.neighbourhood      = neighbourhood
        self.in_odd_even_zone   = in_odd_even_zone
        self.in_traffic_zone    = in_traffic_zone
        self.municipality_zone  = municipality_zone
        self.state              = state
    }
    
    public init(theMapReverse: MapReverse) {
        
        self.address            = theMapReverse.address
        self.city               = theMapReverse.city
        self.neighbourhood      = theMapReverse.neighbourhood
        self.in_odd_even_zone   = theMapReverse.in_odd_even_zone
        self.in_traffic_zone    = theMapReverse.in_traffic_zone
        self.municipality_zone  = theMapReverse.municipality_zone
        self.state              = theMapReverse.state
    }
    
    
    public func formatDataToMakeMapReverse() -> MapReverse {
        return self
    }
    
    public func formatToJSON() -> JSON {
        let result: JSON = ["address": address ?? NSNull(),
                            "city":  city ?? NSNull(),
                            "neighbourhood":       neighbourhood ?? NSNull(),
                            "in_odd_even_zone":     in_odd_even_zone ?? NSNull(),
                            "in_traffic_zone":           in_traffic_zone ?? NSNull(),
                            "municipality_zone":         municipality_zone ?? NSNull(),
                            "state":        state ?? NSNull()]
        return result
    }
    
}
