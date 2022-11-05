//
// SafeDecodable.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

public protocol SafeDecodable: Decodable, CaseIterable, RawRepresentable where RawValue: Decodable, AllCases: BidirectionalCollection {}

public extension SafeDecodable {
    init(from decoder: Decoder) throws {
        self = try Self(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? Self.allCases.last!
    }
}
