//
// ThreadParticipantRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 11/19/22

import ChatDTO
import ChatCore
import Foundation

extension ThreadParticipantRequest: @retroactive ChatSendable, @retroactive SubjectProtocol {}

public extension ThreadParticipantRequest {
    var content: String? { jsonString }
    var subjectId: Int { threadId }
    var chatTypeCodeIndex: Index { typeCodeIndex }

    init(request: ThreadParticipantRequest, admin: Bool) {
        self = request
        self.admin = admin
    }
}

extension ThreadParticipantRequest: @retroactive Paginateable {}
