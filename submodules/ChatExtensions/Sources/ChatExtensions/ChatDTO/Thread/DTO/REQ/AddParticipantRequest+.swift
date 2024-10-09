//
// AddParticipantRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22

import ChatDTO
import ChatCore
import Foundation

extension AddParticipantRequest: ChatSendable, SubjectProtocol {}

public extension AddParticipantRequest {
    var subjectId: Int { threadId }
    var content: String? { jsonString }
    var chatTypeCodeIndex: Index { typeCodeIndex }
}
