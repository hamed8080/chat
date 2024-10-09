//
// UpdateChatProfile+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 11/19/22

import ChatDTO
import ChatCore
import Foundation

extension UpdateChatProfile: ChatSendable {}

public extension UpdateChatProfile {
    var content: String? { jsonString }
    var chatTypeCodeIndex: Index { typeCodeIndex }
}
