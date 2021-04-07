//
//  MapRouting.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini Zhiani on 10/12/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation

public struct Route : Decodable{
    public var overviewPolyline :OverviewPolyline?  = nil
    public var legs             :[Leg]?               = nil
    
    private enum CodingKeys : String , CodingKey{
        case overviewPolyline = "overview_polyline"
        case legs = "legs"
    }
}

public struct Leg :Decodable {
    
    public var summary:     String?
    public var distance:    Distance?
    public var duration:    Duration?
    public var steps:       [Step]?
}

public struct OverviewPolyline : Decodable {
    public var points: String?
}

public struct Distance:Decodable{
    public var value:   Double?
    public var text:    String?
}

public struct Duration : Decodable{
    public var value:   Double?
    public var text:    String?
}

public struct Step:Decodable{
    public var name:            String?
    public var instruction:     String?
    public var rotaryName:      String?
    public var distance:        Distance?
    public var duration:        Duration?
    public var startLocation:   [Double]?
    public var maneuver:   String?
    
    private enum CodingKeys : String , CodingKey{
        case name          = "name"
        case instruction   = "instruction"
        case rotaryName    = "rotaryName"
        case distance      = "distance"
        case duration      = "duration"
        case startLocation = "start_location"
        case maneuver      = "maneuver"
    }
}
