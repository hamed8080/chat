//
// ReactionListRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22

import ChatDTO
import ChatCore
import Foundation

extension ReactionListRequest: @retroactive ChatSendable, @retroactive SubjectProtocol {}

public extension ReactionListRequest {
    var subjectId: Int { conversationId }
    var content: String? { jsonString }
    var chatTypeCodeIndex: Index { typeCodeIndex }
}
