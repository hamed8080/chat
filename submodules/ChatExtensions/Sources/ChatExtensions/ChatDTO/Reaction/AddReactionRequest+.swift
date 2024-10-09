//
// AddReactionRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22

import ChatDTO
import ChatCore
import Foundation

extension AddReactionRequest: ChatSendable, SubjectProtocol {}

public extension AddReactionRequest {
    var subjectId: Int { conversationId }
    var content: String? { jsonString }
    var chatTypeCodeIndex: Index { typeCodeIndex }
}
