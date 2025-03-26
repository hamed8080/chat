//
// AcceptCallRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22

import ChatDTO
import ChatCore
import Foundation

extension AcceptCallRequest: @retroactive ChatSendable, @retroactive SubjectProtocol {}

public extension AcceptCallRequest {
    var subjectId: Int { callId }
    var content: String? { client.jsonString }
    var chatTypeCodeIndex: Index { typeCodeIndex }
}
