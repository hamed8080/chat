//
// SMT.swift
// Copyright (c) 2022 ChatModels
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public enum SMT: Int, Codable, CaseIterable, Identifiable, Sendable {
    public var id: Self { self }
    case isTyping = 1
    case recordVoice = 2
    case uploadPicture = 3
    case uploadVideo = 4
    case uploadSound = 5
    case uploadFile = 6
    case serverTime = -1
    case unknown

    public init(from decoder: Decoder) throws {
        self = try Self(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? Self.allCases.last!
    }
}
