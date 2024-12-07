//
// CreateBotRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatDTO
import ChatCore

extension CreateBotRequest: @retroactive PlainTextSendable {}

public extension CreateBotRequest {
    var content: String? { botName }
    var chatTypeCodeIndex: Index { typeCodeIndex }
}
