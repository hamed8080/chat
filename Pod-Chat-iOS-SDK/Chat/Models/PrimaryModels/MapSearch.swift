//
//  MapSearch.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 10/11/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


open class MapSearch {
    
    public var count:   Int
    public var items:   [MapItem]?
    
    @available(*,deprecated , message:"Removed in 0.10.5.0 version")
    public init(messageContent: JSON) {
        self.count  = messageContent["count"].intValue
        
        if (messageContent["items"] != JSON.null) {
            var myItems = [MapItem]()
            for item in messageContent["items"].arrayValue {
                let theMapItem = MapItem(messageContent: item)
                myItems.append(theMapItem)
            }
            self.items = myItems
        }
        
    }
    
    public init(count:              Int,
                items:              [MapItem]) {
        
        self.count  = count
        self.items  = items
        
    }
    
    @available(*,deprecated , message:"Removed in 0.10.5.0 version")
    public init(theMapSearch: MapSearch) {
        
        self.count  = theMapSearch.count
        self.items  = theMapSearch.items
    }
    
    @available(*,deprecated , message:"Removed in 0.10.5.0 version")
    public func formatDataToMakeMapSearch() -> MapSearch {
        return self
    }

    @available(*,deprecated , message:"Removed in 0.10.5.0 version")
    public func formatToJSON() -> JSON {
        
        var itemsJSON: [JSON] = []
        if let itemsArr = items {
            for item in itemsArr {
                let json = item.formatToJSON()
                itemsJSON.append(json)
            }
        }
        
        let result: JSON = ["count":    count,
                            "items":    itemsJSON]
        return result
    }
    
}





open class MapItem {
    
    public let address:     String?
    public let category:    String?
    public let region:      String?
    public let type:        String?
    public let title:       String?
    
    public var location:    Location?
    
    @available(*,deprecated , message:"Removed in 0.10.5.0 version")
    public init(messageContent: JSON) {
        self.address    = messageContent["address"].string
        self.category   = messageContent["category"].string
        self.region     = messageContent["region"].string
        self.type       = messageContent["type"].string
        self.title      = messageContent["title"].string
        
        if (messageContent["location"] != JSON.null) {
            self.location  = Location(messageContent: messageContent["location"])
        }
    }
    
    
    public init(address:    String?,
                category:   String?,
                region:     String?,
                type:       String?,
                title:      String?,
                location:   Location?) {
        
        self.address    = address
        self.category   = category
        self.region     = region
        self.type       = type
        self.title      = title
        self.location   = location
    }
    
    @available(*,deprecated , message:"Removed in 0.10.5.0 version")
    public init(theMapItem: MapItem) {
        self.address    = theMapItem.address
        self.category   = theMapItem.category
        self.region     = theMapItem.region
        self.type       = theMapItem.type
        self.title      = theMapItem.title
        self.location   = theMapItem.location
    }
    
    @available(*,deprecated , message:"Removed in 0.10.5.0 version")
    public func formatDataToMakeMapItem() -> MapItem {
        return self
    }
    
    @available(*,deprecated , message:"Removed in 0.10.5.0 version")
    public func formatToJSON() -> JSON {
        let result: JSON = ["address":  address ?? NSNull(),
                            "category": category ?? NSNull(),
                            "region":   region ?? NSNull(),
                            "type":     type ?? NSNull(),
                            "title":    title ?? NSNull(),
                            "location": location?.formatToJSON() ?? NSNull()]
        return result
    }
    
}





open class Location {
    
    public let x: Double
    public let y: Double
    public let z: String?
    
    @available(*,deprecated , message:"Removed in 0.10.5.0 version")
    init(messageContent: JSON) {
        self.x  = messageContent["x"].doubleValue
        self.y  = messageContent["y"].doubleValue
        self.z  = messageContent["z"].string
    }
    
    @available(*,deprecated , message:"Removed in 0.10.5.0 version")
    public init(theLocation: Location) {
        self.x  = theLocation.x
        self.y  = theLocation.y
        self.z  = theLocation.z
    }
    
    @available(*,deprecated , message:"Removed in 0.10.5.0 version")
    public func formatDataToMakeLocation() -> Location {
        return self
    }
    
    @available(*,deprecated , message:"Removed in 0.10.5.0 version")
    public func formatToJSON() -> JSON {
        let result: JSON = ["x":    x,
                            "y":    y,
                            "z":    z ?? NSNull()]
        return result
    }
    
}




