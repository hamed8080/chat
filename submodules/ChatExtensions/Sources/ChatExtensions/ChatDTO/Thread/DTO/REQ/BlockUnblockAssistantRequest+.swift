//
// BlockUnblockAssistantRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22


import ChatDTO
import ChatCore
import Foundation

extension BlockUnblockAssistantRequest: ChatSendable {}

public extension BlockUnblockAssistantRequest {
    var content: String? { assistants.jsonString }
    var chatTypeCodeIndex: Index { typeCodeIndex }
}
