//
// RemoveTagParticipantsRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 11/19/22

import ChatDTO
import ChatCore
import Foundation

extension RemoveTagParticipantsRequest: ChatSendable, SubjectProtocol {}

public extension RemoveTagParticipantsRequest {
    var subjectId: Int { tagId }
    var content: String? { tagParticipants.jsonString }
    var chatTypeCodeIndex: Index { typeCodeIndex }
}
