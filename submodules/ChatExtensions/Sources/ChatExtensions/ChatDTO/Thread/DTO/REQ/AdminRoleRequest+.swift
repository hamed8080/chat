//
// AddTagParticipantsRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22

import ChatDTO
import ChatCore
import Foundation

extension AdminRoleRequest: @retroactive ChatSendable, @retroactive SubjectProtocol {}

public extension AdminRoleRequest {
    var subjectId: Int { conversationId }
    var content: String? { invitees.jsonString }
    var chatTypeCodeIndex: Index { typeCodeIndex }
}
