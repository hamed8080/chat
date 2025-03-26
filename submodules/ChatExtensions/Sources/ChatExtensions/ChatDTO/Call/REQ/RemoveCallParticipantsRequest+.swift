//
// RemoveCallParticipantsRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22

import ChatDTO
import ChatCore
import Foundation

extension RemoveCallParticipantsRequest: @retroactive ChatSendable, @retroactive SubjectProtocol {}

public extension RemoveCallParticipantsRequest {
    var subjectId: Int{ callId }
    var content: String? { jsonString }
    var chatTypeCodeIndex: Index { typeCodeIndex }
}
