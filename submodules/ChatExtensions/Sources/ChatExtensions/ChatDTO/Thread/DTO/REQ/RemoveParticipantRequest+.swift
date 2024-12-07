//
// RemoveParticipantRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 11/19/22

import ChatDTO
import ChatCore
import Foundation

extension RemoveParticipantRequest: @retroactive ChatSendable, @retroactive SubjectProtocol {}

public extension RemoveParticipantRequest {
    var content: String? { participantIds?.jsonString ?? invitees?.jsonString }
    var subjectId: Int { threadId }
    var chatTypeCodeIndex: Index { typeCodeIndex }
}
