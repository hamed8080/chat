//
// SendSignalMessageRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22

import ChatDTO
import ChatCore
import Foundation

extension SendSignalMessageRequest: ChatSendable, SubjectProtocol {}

public extension SendSignalMessageRequest {
    var subjectId: Int { threadId }
    var content: String? { jsonString }
    var chatTypeCodeIndex: Index { typeCodeIndex }
}
