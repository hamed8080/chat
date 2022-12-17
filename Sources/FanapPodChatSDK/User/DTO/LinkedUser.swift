//
// LinkedUser.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/2/22

import Foundation

open class LinkedUser: Codable {
    public var coreUserId: Int?
    public var image: String?
    public var name: String?
    public var nickname: String?
    public var username: String?

    public init(coreUserId: Int?,
                image: String?,
                name: String?,
                nickname: String?,
                username: String?)
    {
        self.coreUserId = coreUserId
        self.image = image
        self.name = name
        self.nickname = nickname
        self.username = username
    }
}
