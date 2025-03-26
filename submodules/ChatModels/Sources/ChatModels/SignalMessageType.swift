//
// SignalMessageType.swift
// Copyright (c) 2022 ChatModels
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public enum SignalMessageType: Int, Encodable, Identifiable, CaseIterable, Sendable {
    public var id: Self { self }
    case isTyping = 1
    case recordVoice = 2
    case uploadPicture = 3
    case uploadVideo = 4
    case uploadSound = 5
    case uploadFile = 6

    /// Only when can't decode a type.
    ///
    /// Do not remove or move this property to the top of the enum, it must be the last enum because it uses **SafeDecodable** to decode the last item if no match found.
    case unknown

    public init(from decoder: Decoder) throws {
        self = try Self(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? Self.allCases.last!
    }
}
