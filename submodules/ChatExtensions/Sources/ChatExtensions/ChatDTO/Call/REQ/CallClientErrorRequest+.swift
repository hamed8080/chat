//
// CallClientErrorRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22

import ChatDTO
import ChatCore
import Foundation

extension CallClientErrorRequest: ChatSendable, SubjectProtocol {}

public extension CallClientErrorRequest {
    var subjectId: Int { callId }
    var content: String? { jsonString }
    var chatTypeCodeIndex: Index { typeCodeIndex }
}
