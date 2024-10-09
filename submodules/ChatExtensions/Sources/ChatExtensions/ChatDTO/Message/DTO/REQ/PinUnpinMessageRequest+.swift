//
// PinUnpinMessageRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22

import ChatDTO
import ChatCore
import Foundation

extension PinUnpinMessageRequest: ChatSendable, SubjectProtocol {}

public extension PinUnpinMessageRequest {
    var subjectId: Int { messageId }
    var content: String? { jsonString }
    var chatTypeCodeIndex: Index { typeCodeIndex }
}
