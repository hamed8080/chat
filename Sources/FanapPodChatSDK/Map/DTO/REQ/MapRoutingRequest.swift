//
// MapRoutingRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

public struct Cordinate {
    public let lat: Double
    public let lng: Double

    public init(lat: Double, lng: Double) {
        self.lat = lat
        self.lng = lng
    }
}

public class MapRoutingRequest: BaseRequest, RestAPIProtocol {
    static var config: ChatConfig { Chat.sharedInstance.config! }
    var url: String = "\(config.mapServer)\(Routes.mapRouting.rawValue)"
    var urlString: String { url.toURLCompoenentString(encodable: self) ?? url }
    var headers: [String: String] = ["Api-Key": config.mapApiKey!]
    var bodyData: Data? { toData() }
    var method: HTTPMethod = .get

    public var alternative: Bool = true
    private let destination: Cordinate
    private let origin: Cordinate

    public init(alternative: Bool?, origin: Cordinate, destination: Cordinate, uniqueId: String? = nil) {
        self.alternative = alternative ?? true
        self.destination = origin
        self.origin = destination
        super.init(uniqueId: uniqueId)
    }

    private enum CodingKeys: String, CodingKey {
        case alternative
        case origin
        case destination
    }

    public func encode(to encoder: Encoder) throws {
        var continer = encoder.container(keyedBy: CodingKeys.self)
        try? continer.encode("\(origin.lat),\(origin.lng)", forKey: .origin)
        try? continer.encode("\(destination.lat),\(destination.lng)", forKey: .destination)
        try? continer.encode(alternative, forKey: .alternative)
    }
}
