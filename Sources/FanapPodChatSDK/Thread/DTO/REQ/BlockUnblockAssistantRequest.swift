//
// BlockUnblockAssistantRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/19/22

import Foundation
public class BlockUnblockAssistantRequest: UniqueIdManagerRequest, ChatSendable {
    internal let assistants: [Assistant]
    var chatMessageType: ChatMessageVOTypes = .blockAssistant
    var content: String? { assistants.convertCodableToString() }

    public required init(assistants: [Assistant], uniqueId: String? = nil, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.assistants = assistants
        super.init(uniqueId: uniqueId, typeCodeIndex: typeCodeIndex)
    }
}
