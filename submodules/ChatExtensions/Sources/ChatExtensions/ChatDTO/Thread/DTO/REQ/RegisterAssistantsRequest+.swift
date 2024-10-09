//
// RegisterAssistantsRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 11/19/22

import ChatDTO
import ChatCore
import Foundation

extension RegisterAssistantsRequest: ChatSendable {}

public extension RegisterAssistantsRequest {
    var content: String? { assistants.jsonString }
    var chatTypeCodeIndex: Index { typeCodeIndex }
}
