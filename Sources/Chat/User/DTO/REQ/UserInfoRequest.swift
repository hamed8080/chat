//
// UserInfoRequest.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/19/22

import Foundation
public final class UserInfoRequest: UniqueIdManagerRequest, ChatSendable {
    var chatMessageType: ChatMessageVOTypes = .userInfo
    var content: String?

    override init(uniqueId: String? = nil) {
        super.init(uniqueId: uniqueId)
    }
}
