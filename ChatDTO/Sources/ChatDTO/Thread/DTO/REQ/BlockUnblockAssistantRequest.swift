//
// BlockUnblockAssistantRequest.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/19/22

import Foundation
import ChatCore
import ChatModels

public final class BlockUnblockAssistantRequest: UniqueIdManagerRequest, ChatSendable {
    internal let assistants: [Assistant]
    public var chatMessageType: ChatMessageVOTypes = .blockAssistant
    public var content: String? { assistants.jsonString }

    public required init(assistants: [Assistant], uniqueId: String? = nil) {
        self.assistants = assistants
        super.init(uniqueId: uniqueId)
    }
}
