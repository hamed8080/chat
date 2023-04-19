//
// Route.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/2/22

import Foundation

public struct Route: Decodable {
    public var overviewPolyline: OverviewPolyline?
    public var legs: [Leg]?

    private enum CodingKeys: String, CodingKey {
        case overviewPolyline = "overview_polyline"
        case legs
    }
}

public struct Leg: Decodable {
    public var summary: String?
    public var distance: Distance?
    public var duration: Duration?
    public var steps: [Step]?
}

public struct OverviewPolyline: Decodable {
    public var points: String?
}

public struct Distance: Decodable {
    public var value: Double?
    public var text: String?
}

public struct Duration: Decodable {
    public var value: Double?
    public var text: String?
}

public struct Step: Decodable {
    public var name: String?
    public var instruction: String?
    public var rotaryName: String?
    public var distance: Distance?
    public var duration: Duration?
    public var startLocation: [Double]?
    public var maneuver: String?

    private enum CodingKeys: String, CodingKey {
        case name
        case instruction
        case rotaryName
        case distance
        case duration
        case startLocation = "start_location"
        case maneuver
    }
}
