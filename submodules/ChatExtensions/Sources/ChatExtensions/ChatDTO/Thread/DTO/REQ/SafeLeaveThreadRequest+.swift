//
// SafeLeaveThreadRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 11/2/22

import ChatDTO
import ChatCore
import Foundation

extension SafeLeaveThreadRequest: ChatSendable, SubjectProtocol {}

public extension SafeLeaveThreadRequest {
    var subjectId: Int { threadId }
    var content: String? { jsonString }
    var chatTypeCodeIndex: Index { typeCodeIndex }
}
