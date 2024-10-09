//
// MuteCallRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22

import ChatDTO
import ChatCore
import Foundation

extension MuteCallRequest: ChatSendable, SubjectProtocol {}

public extension MuteCallRequest {
    var subjectId: Int { callId }
    var content: String? { userIds.jsonString }
    var chatTypeCodeIndex: Index { typeCodeIndex }
}
