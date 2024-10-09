//
// UpdateThreadInfoRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 11/19/22

import ChatDTO
import ChatCore
import Foundation

extension UpdateThreadInfoRequest: ChatSendable, SubjectProtocol {}

public extension UpdateThreadInfoRequest {
    var subjectId: Int { threadId }
    var content: String? { jsonString }
    var chatTypeCodeIndex: Index { typeCodeIndex }
}
