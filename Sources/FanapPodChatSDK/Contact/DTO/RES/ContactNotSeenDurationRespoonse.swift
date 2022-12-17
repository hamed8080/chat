//
// ContactNotSeenDurationRespoonse.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/2/22

import Foundation

open class UserLastSeenDuration: Codable {
    public var userId: Int
    public var time: Int

    init(userId: Int, time: Int) {
        self.userId = userId
        self.time = time
    }
}

open class ContactNotSeenDurationRespoonse: Decodable {
    public let notSeenDuration: [UserLastSeenDuration]

    public required init(from decoder: Decoder) throws {
        if let unkeyedContainer = try? decoder.singleValueContainer(), let dictionary = try? unkeyedContainer.decode([String: Int?].self) {
            notSeenDuration = dictionary.map { UserLastSeenDuration(userId: Int($0) ?? 0, time: $1 ?? 0) }
        } else {
            notSeenDuration = []
        }
    }
}
