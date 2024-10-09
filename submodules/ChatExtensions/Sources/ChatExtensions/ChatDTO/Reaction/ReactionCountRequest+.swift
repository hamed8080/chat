//
// ReactionCountRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22

import ChatDTO
import ChatCore
import Foundation

extension ReactionCountRequest: ChatSendable, SubjectProtocol {}

public extension ReactionCountRequest {
    var subjectId: Int { conversationId }
    var content: String? { "\(messageIds)" }
    var chatTypeCodeIndex: Index { typeCodeIndex }
}
