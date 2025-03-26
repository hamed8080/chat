//
// DeleteMessageRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatCore
import ChatDTO

extension DeleteMessageRequest: @retroactive ChatSendable, @retroactive SubjectProtocol {}

public extension DeleteMessageRequest {
    var content: String? { jsonString }
    var subjectId: Int { messageId }
    var chatTypeCodeIndex: Index { typeCodeIndex }
}
