//
// UnreadMessageCountRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22

import ChatDTO
import ChatCore
import Foundation

extension AllThreadsUnreadCountRequest: ChatSendable {}

public extension AllThreadsUnreadCountRequest {
    var content: String? { jsonString }
    var chatTypeCodeIndex: Index { typeCodeIndex }
}
