//
//  MapRouting.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 10/12/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


open class MapRouting {
    
    public var routs:   [MapRoutingRout]?
    
    @available(*,deprecated , message:"Removed in 0.10.5.0 version")
    public init(messageContent: JSON) {
        
        if (messageContent["routs"] != JSON.null) {
            var myItems = [MapRoutingRout]()
            for item in messageContent["items"].arrayValue {
                let theMapItem = MapRoutingRout(messageContent: item)
                myItems.append(theMapItem)
            }
            self.routs = myItems
        }
        
    }
    
    @available(*,deprecated , message:"Removed in 0.10.5.0 version")
    public init(routs: [MapRoutingRout]) {
        
        self.routs = routs
        
    }
    
    @available(*,deprecated , message:"Removed in 0.10.5.0 version")
    public init(theMapRouting: MapRouting) {
        
        self.routs = theMapRouting.routs
    }
    
    
    public func formatDataToMakeMapRouting() -> MapRouting {
        return self
    }
    
    @available(*,deprecated , message:"Removed in 0.10.5.0 version")
    public func formatToJSON() -> JSON {
        
        var itemsJSON: [JSON] = []
        if let itemsArr = routs {
            for item in itemsArr {
                let json = item.formatToJSON()
                itemsJSON.append(json)
            }
        }
        
        let result: JSON = ["routs":    itemsJSON]
        return result
    }
    
}



open class MapRoutingRout {
    
    public var overview_polyline:   MapRoutOverviewPolyline
    public var legs:                [MapRoutLegs]
    
    @available(*,deprecated , message:"Removed in 0.10.5.0 version")
    public init(messageContent: JSON) {
        
        self.overview_polyline  = MapRoutOverviewPolyline(messageContent: messageContent["overview_polyline"])
        
        var myItems = [MapRoutLegs]()
        for item in messageContent["legs"].arrayValue {
            let theMapRoutItem = MapRoutLegs(messageContent: item)
            myItems.append(theMapRoutItem)
        }
        self.legs = myItems
    }
    
    
    public init(overview_polyline:  MapRoutOverviewPolyline,
                legs:               [MapRoutLegs]) {
        
        self.overview_polyline  = overview_polyline
        self.legs               = legs
    }
    
    
    public init(theMapRout: MapRoutingRout) {
        self.overview_polyline  = theMapRout.overview_polyline
        self.legs               = theMapRout.legs
    }
    
    @available(*,deprecated , message:"Removed in 0.10.5.0 version")
    public func formatDataToMakeMapItem() -> MapRoutingRout {
        return self
    }
    
    @available(*,deprecated , message:"Removed in 0.10.5.0 version")
    public func formatToJSON() -> JSON {
        
        var legsJSON: [JSON] = []
        let itemsArr = legs
        for item in itemsArr {
            let json = item.formatToJSON()
            legsJSON.append(json)
        }
        
        let result: JSON = ["overview_polyline":    overview_polyline.formatToJSON(),
                            "legs":                 legsJSON]
        return result
    }
    
}



open class MapRoutOverviewPolyline {
    
    public var points: String?

    @available(*,deprecated , message:"Removed in 0.10.5.0 version")
    init(messageContent: JSON) {
        self.points  = messageContent["points"].string
    }
    
    public init(points: MapRoutOverviewPolyline) {
        self.points  = points.points
    }
    
    @available(*,deprecated , message:"Removed in 0.10.5.0 version")
    public func formatDataToMakeMapRoutOverviewPolyline() -> MapRoutOverviewPolyline {
        return self
    }
    
    @available(*,deprecated , message:"Removed in 0.10.5.0 version")
    public func formatToJSON() -> JSON {
        let result: JSON = ["points":   points ?? NSNull()]
        return result
    }
    
}



open class MapRoutLegs {
    
    public var summary:     String?
    public var distance:    MapRoutLegsDistanceDuration?
    public var duration:    MapRoutLegsDistanceDuration?
    public var steps:       [MapRoutLegsSteps]?
    
    
    init(messageContent: JSON) {
        
        self.summary  = messageContent["summary"].string
        
        self.distance  = MapRoutLegsDistanceDuration(messageContent: messageContent["distance"])
        self.duration  = MapRoutLegsDistanceDuration(messageContent: messageContent["duration"])
//        if (messageContent["distance"] != nil) {
//            self.distance  = MapRoutLegsDistanceDuration(messageContent: messageContent["distance"])
//        }
//        if (messageContent["duration"] != nil) {
//            self.duration  = MapRoutLegsDistanceDuration(messageContent: messageContent["duration"])
//        }
        
        if (messageContent["steps"] != JSON.null) {
            var mySteps = [MapRoutLegsSteps]()
            for item in messageContent["steps"].arrayValue {
                let theMapItemStep = MapRoutLegsSteps(messageContent: item)
                mySteps.append(theMapItemStep)
            }
            self.steps = mySteps
        }
    }
    
    public init(legs: MapRoutLegs) {
        self.summary    = legs.summary
        self.distance   = legs.distance
        self.duration   = legs.duration
        self.steps      = legs.steps
    }
    
    public init(summary: String?,
                distance:   MapRoutLegsDistanceDuration?,
                duration:   MapRoutLegsDistanceDuration?,
                steps:      [MapRoutLegsSteps]?) {
        
        self.summary    = summary
        self.distance   = distance
        self.duration   = duration
        self.steps      = steps
    }
    
    public func formatDataToMakeMapRoutLegs() -> MapRoutLegs {
        return self
    }
    
    public func formatToJSON() -> JSON {
        
        var stepsJSON: [JSON] = []
        if let itemsArr = steps {
            for item in itemsArr {
                let json = item.formatToJSON()
                stepsJSON.append(json)
            }
        }
        
        let result: JSON = ["summary":  summary ?? NSNull(),
                            "distance": distance?.formatToJSON() ?? NSNull(),
                            "duration": duration?.formatToJSON() ?? NSNull(),
                            "steps":    stepsJSON]
        return result
    }
    
}



open class MapRoutLegsDistanceDuration {
    
    public var value:   Int?
    public var text:    String?
    
    init(messageContent: JSON) {
        self.value  = messageContent["value"].int
        self.text   = messageContent["text"].string
    }
    
    public init(points: MapRoutLegsDistanceDuration) {
        self.value  = points.value
        self.text   = points.text
    }
    
    public init(value:  Int?,
                text:   String?) {
        self.value  = value
        self.text   = text
    }
    
    public func formatDataToMakeMapRoutLegsDistance() -> MapRoutLegsDistanceDuration {
        return self
    }
    
    public func formatToJSON() -> JSON {
        let result: JSON = ["value":    value ?? NSNull(),
                            "text":     text ?? NSNull()]
        return result
    }
    
}



open class MapRoutLegsSteps {
    
    public var name:            String?
    public var instruction:     String?
    public var rotaryName:      String?
    public var distance:        MapRoutLegsDistanceDuration?
    public var duration:        MapRoutLegsDistanceDuration?
    public var start_location:  [Double]?
    
    
    init(messageContent: JSON) {
        
        self.name  = messageContent["name"].string
        self.instruction   = messageContent["instruction"].string
        self.rotaryName   = messageContent["rotaryName"].string
        
        self.distance  = MapRoutLegsDistanceDuration(messageContent: messageContent["distance"])
        self.duration  = MapRoutLegsDistanceDuration(messageContent: messageContent["duration"])
//        if (messageContent["distance"] != nil) {
//            self.distance  = MapRoutLegsDistanceDuration(messageContent: messageContent["distance"])
//        }
//        if (messageContent["duration"] != nil) {
//            self.duration  = MapRoutLegsDistanceDuration(messageContent: messageContent["duration"])
//        }
        
        if let locationArr = messageContent["start_location"].array as? [Double]? {
            self.start_location = locationArr
        }
    }
    
    public init(steps: MapRoutLegsSteps) {
        
        self.name           = steps.name
        self.instruction    = steps.instruction
        self.rotaryName     = steps.rotaryName
        self.distance       = steps.distance
        self.duration       = steps.duration
        self.start_location = steps.start_location
    }
    
    public init(name:           String?,
                instruction:    String?,
                rotaryName:     String?,
                distance:       MapRoutLegsDistanceDuration?,
                duration:       MapRoutLegsDistanceDuration?,
                start_location: [Double]?) {
        
        self.name           = name
        self.instruction    = instruction
        self.rotaryName     = rotaryName
        self.distance       = distance
        self.duration       = duration
        self.start_location = start_location
    }
    
    public func formatDataToMakeMapRoutLegsSteps() -> MapRoutLegsSteps {
        return self
    }
    
    public func formatToJSON() -> JSON {
        let result: JSON = ["name":             name ?? NSNull(),
                            "instruction":      instruction ?? NSNull(),
                            "rotaryName":       rotaryName ?? NSNull(),
                            "distance":         distance?.formatToJSON() ?? NSNull(),
                            "duration":         duration?.formatToJSON() ?? NSNull(),
                            "start_location":   start_location ?? NSNull()]
        return result
    }
    
}






