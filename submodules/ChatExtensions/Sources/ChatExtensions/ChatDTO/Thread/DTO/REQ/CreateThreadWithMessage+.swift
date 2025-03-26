//
// CreateThreadWithMessage+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22

import ChatDTO
import ChatCore
import Foundation

extension CreateThreadWithMessage: @retroactive ChatSendable {}

public extension CreateThreadWithMessage {
    var content: String? { jsonString }
    var chatTypeCodeIndex: Index { typeCodeIndex }
}
