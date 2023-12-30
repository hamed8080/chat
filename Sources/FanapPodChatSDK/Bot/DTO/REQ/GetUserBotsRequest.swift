//
// GetUserBotsRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/19/22

import Foundation

/// The request to fetch the list of user bots.
public class GetUserBotsRequest: UniqueIdManagerRequest, ChatSendable {
    var chatMessageType: ChatMessageVOTypes = .getUserBots
    var content: String?

    override public init(uniqueId: String? = nil, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        super.init(uniqueId: uniqueId, typeCodeIndex: typeCodeIndex)
    }
}
