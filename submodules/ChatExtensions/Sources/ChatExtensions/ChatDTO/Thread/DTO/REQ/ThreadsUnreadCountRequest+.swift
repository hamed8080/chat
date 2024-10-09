//
// ThreadsRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 11/19/22


import ChatDTO
import ChatCore
import Foundation

extension ThreadsUnreadCountRequest: ChatSendable {}

public extension ThreadsUnreadCountRequest {
    var content: String? { threadIds.jsonString }
    var chatTypeCodeIndex: Index { typeCodeIndex }
}
