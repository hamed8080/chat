//
// AuditorRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 11/19/22

import ChatDTO
import ChatCore
import Foundation

extension AuditorRequest: @retroactive ChatSendable, @retroactive SubjectProtocol {}

public extension AuditorRequest {
    var content: String? { userRoles.jsonString }
    var subjectId: Int { threadId }
    var chatTypeCodeIndex: Index { typeCodeIndex }
}
