//
// DeactiveAssistantRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/19/22

import Foundation
public class DeactiveAssistantRequest: UniqueIdManagerRequest, ChatSendable {
    public let assistants: [Assistant]
    var content: String? { assistants.convertCodableToString() }
    var chatMessageType: ChatMessageVOTypes = .deacticveAssistant

    public init(assistants: [Assistant], uniqueId: String? = nil) {
        self.assistants = assistants
        super.init(uniqueId: uniqueId)
    }
}
