//
// AddTagParticipantsRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22

import ChatDTO
import ChatCore
import Foundation

extension AddTagParticipantsRequest: @retroactive ChatSendable, @retroactive SubjectProtocol  {}

public extension AddTagParticipantsRequest {
    var subjectId: Int { tagId }
    var content: String? { threadIds.jsonString }
    var chatTypeCodeIndex: Index { typeCodeIndex }
}
