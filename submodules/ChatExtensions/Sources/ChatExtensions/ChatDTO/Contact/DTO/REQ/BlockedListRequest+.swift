//
// BlockedListRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatDTO
import ChatCore

extension BlockedListRequest: @retroactive ChatSendable {}

public extension BlockedListRequest {
    var content: String? { jsonString }
    var chatTypeCodeIndex: Index { typeCodeIndex }
}

extension BlockedListRequest: @retroactive Paginateable {}
