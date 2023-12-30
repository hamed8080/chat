//
// UserInfoRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/19/22

import Foundation
public class UserInfoRequest: UniqueIdManagerRequest, ChatSendable {
    var chatMessageType: ChatMessageVOTypes = .userInfo
    var content: String?

    override init(uniqueId: String? = nil, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        super.init(uniqueId: uniqueId, typeCodeIndex: typeCodeIndex)
    }
}
