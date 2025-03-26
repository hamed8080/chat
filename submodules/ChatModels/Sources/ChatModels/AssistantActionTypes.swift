//
// AssistantActionTypes.swift
// Copyright (c) 2022 ChatModels
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public enum AssistantActionTypes: Int, Codable, Identifiable, CaseIterable, Sendable {
    public var id: Self { self }
    case register = 1
    case activate = 2
    case deactivate = 3
    case block = 4
    case unblock = 5

    /// Only when can't decode a type.
    ///
    /// Do not remove or move this property to the top of the enum, it must be the last enum because it uses **SafeDecodable** to decode the last item if no match found.
    case unknown

    public init(from decoder: Decoder) throws {
        self = try Self(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? Self.allCases.last!
    }
}
