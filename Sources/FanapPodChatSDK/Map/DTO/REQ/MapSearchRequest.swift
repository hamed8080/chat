//
// MapSearchRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

public class MapSearchRequest: BaseRequest, RestAPIProtocol {
    static let config = Chat.sharedInstance.config!
    var url: String = "\(config.mapServer)\(Routes.mapSearch.rawValue)"
    var urlString: String { url.toURLCompoenentString(encodable: self) ?? url }
    var headers: [String: String] = ["Api-Key": config.mapApiKey!]
    var bodyData: Data? { toData() }
    var method: HTTPMethod = .get

    public let lat: Double
    public let lng: Double
    public let term: String

    public init(lat: Double,
                lng: Double,
                term: String,
                uniqueId: String? = nil)
    {
        self.lat = lat
        self.lng = lng
        self.term = term
        super.init(uniqueId: uniqueId)
    }

    private enum CodingKeys: String, CodingKey {
        case lat
        case lng
        case term
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(lat, forKey: .lat)
        try? container.encode(lng, forKey: .lng)
        try? container.encode(term, forKey: .term)
    }
}
