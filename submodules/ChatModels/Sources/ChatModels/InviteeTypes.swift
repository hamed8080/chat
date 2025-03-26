//
// InviteeTypes.swift
// Copyright (c) 2022 ChatModels
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public enum InviteeTypes: Int, Codable, CaseIterable, Sendable {
    case ssoId = 1
    case contactId = 2
    case cellphoneNumber = 3
    case username = 4
    case userId = 5
    case coreUserId = 6

    /// Only when can't decode a type.
    ///
    /// Do not remove or move this property to the top of the enum, it must be the last enum because it uses **SafeDecodable** to decode the last item if no match found.
    case unknown

    public init(from decoder: Decoder) throws {
        self = try Self(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? Self.allCases.last!
    }
}
