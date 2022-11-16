//
// RegisterAssistantRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public class RegisterAssistantRequest: BaseRequest, ChatSnedable {
    public let assistants: [Assistant]
    var content: String? { assistants.convertCodableToString() }
    var chatMessageType: ChatMessageVOTypes = .registerAssistant

    public init(assistants: [Assistant], uniqueId: String? = nil) {
        self.assistants = assistants
        super.init(uniqueId: uniqueId)
    }
}
