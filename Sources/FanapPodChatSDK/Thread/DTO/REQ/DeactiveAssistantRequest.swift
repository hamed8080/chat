//
// DeactiveAssistantRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public class DeactiveAssistantRequest: UniqueIdManagerRequest, ChatSnedable {
    public let assistants: [Assistant]
    var content: String? { assistants.convertCodableToString() }
    var chatMessageType: ChatMessageVOTypes = .deacticveAssistant

    public init(assistants: [Assistant], uniqueId: String? = nil) {
        self.assistants = assistants
        super.init(uniqueId: uniqueId)
    }
}
