//
// RemoveContactResponse.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/2/22

import Foundation
public final class RemoveContactResponse: Decodable {
    public var deteled: Bool

    private enum CodingKeys: String, CodingKey {
        case result
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        deteled = try container.decodeIfPresent(Bool.self, forKey: .result) ?? false
    }
}
