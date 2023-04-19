//
// UserInfoRequest.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/19/22

import Foundation
import ChatCore

public final class UserInfoRequest: UniqueIdManagerRequest, ChatSendable {
    public var chatMessageType: ChatMessageVOTypes = .userInfo
    public var content: String?

    public override init(uniqueId: String? = nil) {
        super.init(uniqueId: uniqueId)
    }
}
