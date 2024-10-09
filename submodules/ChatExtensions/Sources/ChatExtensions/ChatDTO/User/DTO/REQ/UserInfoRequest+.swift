//
// UserInfoRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 11/19/22

import ChatDTO
import ChatCore
import Foundation

extension UserInfoRequest: ChatSendable {}

public extension UserInfoRequest {
    var content: String? { nil }
    var chatTypeCodeIndex: Index { typeCodeIndex }
}
