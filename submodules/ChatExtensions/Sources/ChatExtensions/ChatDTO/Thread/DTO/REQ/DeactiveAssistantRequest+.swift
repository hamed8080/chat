//
// DeactiveAssistantRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22

import ChatDTO
import ChatCore
import Foundation

extension DeactiveAssistantRequest: @retroactive ChatSendable {}

public extension DeactiveAssistantRequest {
    var content: String? { assistants.jsonString }
    var chatTypeCodeIndex: Index { typeCodeIndex }
}
