//
// CancelCallRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22

import ChatDTO
import ChatCore
import Foundation

extension CancelCallRequest: ChatSendable, SubjectProtocol {}

public extension CancelCallRequest {
    var subjectId: Int { call.id }
    var content: String? { call.jsonString }
    var chatTypeCodeIndex: Index { typeCodeIndex }
}
