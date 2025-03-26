//
// AddBotCommandRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatDTO
import ChatCore

extension AddBotCommandRequest: @retroactive ChatSendable {
}

public extension AddBotCommandRequest {
    var content: String? { return nil }
    var chatTypeCodeIndex: Index { typeCodeIndex }
}
