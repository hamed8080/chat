//
// UserReactionRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22

import ChatDTO
import ChatCore
import Foundation

extension UserReactionRequest: ChatSendable, SubjectProtocol {}

public extension UserReactionRequest {
    var subjectId: Int { conversationId }
    var content: String? { jsonString }
    var chatTypeCodeIndex: Index { typeCodeIndex }
}
