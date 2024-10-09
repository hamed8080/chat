//
// RenewCallRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22

import ChatDTO
import ChatCore
import Foundation

extension RenewCallRequest: ChatSendable, SubjectProtocol {}

public extension RenewCallRequest {
    var subjectId: Int { callId }
    var content: String? { invitess.jsonString }
    var chatTypeCodeIndex: Index { typeCodeIndex }
}
