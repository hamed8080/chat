//
// AddCallParticipantsRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22

import ChatDTO
import ChatCore
import Foundation

extension AddCallParticipantsRequest: ChatSendable, SubjectProtocol {}

public extension AddCallParticipantsRequest {
    var subjectId: Int { callId }
    var content: String? { jsonString }
    var chatTypeCodeIndex: Index { typeCodeIndex }
}
