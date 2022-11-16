//
// UserInfoRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public class UserInfoRequest: UniqueIdManagerRequest, ChatSnedable {
    var chatMessageType: ChatMessageVOTypes = .userInfo
    var content: String?

    override init(uniqueId: String? = nil) {
        super.init(uniqueId: uniqueId)
    }
}
