//
// LastActionInConversationRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22

import ChatDTO
import ChatCore
import Foundation

extension LastActionInConversationRequest: ChatSendable {}

public extension LastActionInConversationRequest {
    var content: String? { ids.jsonString }
    var chatTypeCodeIndex: Index { typeCodeIndex }
}
