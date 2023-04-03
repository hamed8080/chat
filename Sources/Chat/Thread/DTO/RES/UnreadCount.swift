//
// UnreadCount.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/2/22

import Foundation

public struct UnreadCount: Decodable {
    public let unreadCount: Int?
    public let threadId: Int?
}
