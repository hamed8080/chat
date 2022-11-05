//
// CallStatus.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public enum CallStatus: Int, Codable {
    case requested = 1
    case canceled = 2
    case miss = 3
    case declined = 4
    case accepted = 5
    case started = 6
    case ended = 7
    case leave = 8

    case unknown

    // prevent crash when new case added from server side
    public init(from decoder: Decoder) throws {
        guard let value = try? decoder.singleValueContainer().decode(Int.self) else {
            self = .unknown
            return
        }
        self = CallStatus(rawValue: value) ?? .unknown
    }
}
