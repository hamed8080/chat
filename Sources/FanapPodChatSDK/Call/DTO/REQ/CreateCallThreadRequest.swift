//
// CreateCallThreadRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public struct CreateCallThreadRequest: Encodable {
    let title: String?
    let image: String?
    let description: String?
    let metadata: String?
    let uniqueName: String?

    public init(title: String? = nil, image: String? = nil, description: String? = nil, metadata: String? = nil, uniqueName: String? = nil) {
        self.title = title
        self.image = image
        self.description = description
        self.metadata = metadata
        self.uniqueName = uniqueName
    }

    private enum CodingKeys: String, CodingKey {
        case title
        case image
        case description
        case metadata
        case uniqueName
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(image, forKey: .image)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(metadata, forKey: .metadata)
        try container.encodeIfPresent(uniqueName, forKey: .uniqueName)
    }
}
