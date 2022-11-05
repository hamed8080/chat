//
// AsyncMessageEX.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation
extension AsyncMessage {
    var chatMessage: ChatMessage? {
        guard
            let chatMessageData = content?.data(using: .utf8),
            let chatMessage = try? JSONDecoder().decode(ChatMessage.self, from: chatMessageData) else { return nil }
        return chatMessage
    }
}
