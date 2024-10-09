//
// StartStopBotRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatCore
import ChatDTO

extension StartStopBotRequest: ChatSendable, SubjectProtocol {}

public extension StartStopBotRequest {
    var subjectId: Int { threadId }
    var content: String? { jsonString }
    var chatTypeCodeIndex: Index { typeCodeIndex }
}
