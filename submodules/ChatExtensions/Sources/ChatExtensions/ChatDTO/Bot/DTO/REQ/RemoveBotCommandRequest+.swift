//
// RemoveBotCommandRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatDTO
import ChatCore

extension RemoveBotCommandRequest: @retroactive ChatSendable {}

public extension RemoveBotCommandRequest {
    var content: String? { jsonString }
    var chatTypeCodeIndex: Index { typeCodeIndex }
}
