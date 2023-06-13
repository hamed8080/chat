//
// MapProtocol.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import ChatDTO
import ChatCore
import Foundation

public protocol MapProtocol {
    /// Convert a location to an image.
    /// - Parameters:
    ///   - request: The request size and location.
    func image(_ request: MapStaticImageRequest)

    /// Convert latitude and longitude to a human-readable address.
    /// - Parameters:
    ///   - request: Request of getting address.
    func reverse(_ request: MapReverseRequest)

    /// Find a route between two places.
    /// - Parameters:
    ///   - request: The request that contains origin and destination.
    func routes(_ request: MapRoutingRequest)

    /// Search for Items inside an area.
    /// - Parameters:
    ///   - request: Request of area.
    func search(_ request: MapSearchRequest)
}

protocol InternalMapProtocol: MapProtocol {
    func image(_ request: MapStaticImageRequest, _ completion: ((ChatResponse<Data>) -> Void)?)
}
