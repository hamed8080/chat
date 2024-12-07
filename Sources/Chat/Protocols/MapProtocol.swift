//
// MapProtocol.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import ChatCore
import ChatDTO
import Foundation

@ChatGlobalActor
public protocol MapProtocol: AnyObject {
    /// Convert a location to an image.
    /// - Parameters:
    ///   - request: The request size and location.
    func image(_ request: MapStaticImageRequest) async throws -> Data?

    /// Convert latitude and longitude to a human-readable address.
    /// - Parameters:
    ///   - request: Request of getting address.
    func reverse(_ request: MapReverseRequest) async throws -> MapReverse?

    /// Find a route between two places.
    /// - Parameters:
    ///   - request: The request that contains origin and destination.
    func routes(_ request: MapRoutingRequest) async throws -> [Route]?

    /// Search for Items inside an area.
    /// - Parameters:
    ///   - request: Request of area.
    func search(_ request: MapSearchRequest) async throws -> [MapItem]?
}
