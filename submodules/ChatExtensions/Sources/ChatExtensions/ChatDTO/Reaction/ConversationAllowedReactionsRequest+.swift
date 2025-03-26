//
// ConversationAllowedReactionsRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22

import ChatDTO
import ChatCore
import Foundation

extension ConversationAllowedReactionsRequest: @retroactive ChatSendable, @retroactive SubjectProtocol {}

public extension ConversationAllowedReactionsRequest {
    var subjectId: Int { conversationId }
    var content: String? { nil }
    var chatTypeCodeIndex: Index { typeCodeIndex }
}
