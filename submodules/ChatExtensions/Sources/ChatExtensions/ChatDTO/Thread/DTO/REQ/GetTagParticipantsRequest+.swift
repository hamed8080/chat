//
// GetTagParticipantsRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22

import ChatDTO
import ChatCore
import Foundation

extension GetTagParticipantsRequest: ChatSendable, SubjectProtocol {}

public extension GetTagParticipantsRequest {
    var subjectId: Int { id }
    var content: String? { nil }
    var chatTypeCodeIndex: Index { typeCodeIndex }
}
