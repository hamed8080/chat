//
// MentionRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22

import ChatDTO
import ChatCore
import Foundation

extension MentionRequest: @retroactive ChatSendable, @retroactive SubjectProtocol {}

public extension MentionRequest {
    var content: String? { jsonString }
    var subjectId: Int { threadId }
    var chatTypeCodeIndex: Index { typeCodeIndex }
}
