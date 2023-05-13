//
// MapProtocol.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import ChatDTO
import Foundation

public protocol MapProtocol {
    /// Convert a location to an image.
    /// - Parameters:
    ///   - request: The request size and location.
    ///   - completion: Data of image.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func mapStaticImage(_ request: MapStaticImageRequest, downloadProgress: DownloadProgressType?, completion: @escaping CompletionType<Data?>, uniqueIdResult: UniqueIdResultType?)

    /// Convert latitude and longitude to a human-readable address.
    /// - Parameters:
    ///   - request: Request of getting address.
    ///   - completion: Response of reverse address.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func mapReverse(_ request: MapReverseRequest, completion: @escaping CompletionType<MapReverse>, uniqueIdResult: UniqueIdResultType?)

    /// Find a route between two places.
    /// - Parameters:
    ///   - request: The request that contains origin and destination.
    ///   - completion: Response of request.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func mapRouting(_ request: MapRoutingRequest, completion: @escaping CompletionType<[Route]>, uniqueIdResult: UniqueIdResultType?)

    /// Search for Items inside an area.
    /// - Parameters:
    ///   - request: Request of area.
    ///   - completion: Reponse of founded items.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func mapSearch(_ request: MapSearchRequest, completion: @escaping CompletionType<[MapItem]>, uniqueIdResult: UniqueIdResultType?)
}

public extension MapProtocol {
    /// Convert a location to an image.
    /// - Parameters:
    ///   - request: The request size and location.
    ///   - completion: Data of image.
    func mapStaticImage(_ request: MapStaticImageRequest, downloadProgress: DownloadProgressType?, completion: @escaping CompletionType<Data?>) {
        mapStaticImage(request, downloadProgress: downloadProgress, completion: completion, uniqueIdResult: nil)
    }

    /// Convert latitude and longitude to a human-readable address.
    /// - Parameters:
    ///   - request: Request of getting address.
    ///   - completion: Response of reverse address.
    func mapReverse(_ request: MapReverseRequest, completion: @escaping CompletionType<MapReverse>) {
        mapReverse(request, completion: completion, uniqueIdResult: nil)
    }

    /// Find a route between two places.
    /// - Parameters:
    ///   - request: The request that contains origin and destination.
    ///   - completion: Response of request.
    func mapRouting(_ request: MapRoutingRequest, completion: @escaping CompletionType<[Route]>) {
        mapRouting(request, completion: completion, uniqueIdResult: nil)
    }

    /// Search for Items inside an area.
    /// - Parameters:
    ///   - request: Request of area.
    ///   - completion: Reponse of founded items.
    func mapSearch(_ request: MapSearchRequest, completion: @escaping CompletionType<[MapItem]>, uniqueIdResult _: UniqueIdResultType?) {
        mapSearch(request, completion: completion, uniqueIdResult: nil)
    }
}
