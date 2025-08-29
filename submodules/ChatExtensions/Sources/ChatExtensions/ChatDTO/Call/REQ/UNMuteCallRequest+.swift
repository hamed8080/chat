//
// UNMuteCallRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22

import ChatDTO
import ChatCore
import Foundation

extension UNMuteCallParitcipantsRequest: @retroactive ChatSendable, @retroactive SubjectProtocol {}

public extension UNMuteCallParitcipantsRequest {
    var subjectId: Int { callId }
    var content: String? { userIds.jsonString }
    var chatTypeCodeIndex: Index { typeCodeIndex }
}
