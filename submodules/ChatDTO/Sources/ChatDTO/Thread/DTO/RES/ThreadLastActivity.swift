//
// ThreadLastActivity.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct ThreadLastActivity: Decodable, Sendable {
    public let time: Int?
    public let threadId: Int?

    public init(time: Int?, threadId: Int?) {
        self.time = time
        self.threadId = threadId
    }
}
