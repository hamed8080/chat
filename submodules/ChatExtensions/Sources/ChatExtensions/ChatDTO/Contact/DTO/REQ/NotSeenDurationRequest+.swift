//
// NotSeenDurationRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatDTO
import ChatCore

extension NotSeenDurationRequest: ChatSendable {}

public extension NotSeenDurationRequest {
    var content: String? { jsonString }
    var chatTypeCodeIndex: Index { typeCodeIndex }
}
