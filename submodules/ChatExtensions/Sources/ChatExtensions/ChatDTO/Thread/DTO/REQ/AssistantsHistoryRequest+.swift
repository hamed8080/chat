//
// AssistantsHistoryRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22

import ChatDTO
import ChatCore
import Foundation

extension AssistantsHistoryRequest: @retroactive ChatSendable {}

public extension AssistantsHistoryRequest {
    var content: String? { jsonString }
    var chatTypeCodeIndex: Index { typeCodeIndex }
}

extension AssistantsHistoryRequest: @retroactive Paginateable{}
