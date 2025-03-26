//
// RolesRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 11/19/22

import ChatDTO
import ChatCore
import Foundation

extension RolesRequest: @retroactive ChatSendable, @retroactive SubjectProtocol {}

public extension RolesRequest {
    var content: String? { userRoles.jsonString }
    var subjectId: Int { threadId }
    var chatTypeCodeIndex: Index { typeCodeIndex }
}
