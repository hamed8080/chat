//
// MessageSeenRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22

import ChatDTO
import ChatCore
import Foundation

extension MessageSeenRequest: @retroactive PlainTextSendable {}

public extension MessageSeenRequest {
    var content: String? { "\(messageId)" }
    var chatTypeCodeIndex: Index { typeCodeIndex }
}
