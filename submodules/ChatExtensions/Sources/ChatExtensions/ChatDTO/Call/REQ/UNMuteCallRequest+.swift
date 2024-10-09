//
// UNMuteCallRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22

import ChatDTO
import ChatCore
import Foundation

extension UNMuteCallRequest: ChatSendable, SubjectProtocol {}

public extension UNMuteCallRequest {
    var subjectId: Int { callId }
    var content: String? { userIds.jsonString }
    var chatTypeCodeIndex: Index { typeCodeIndex }
}
