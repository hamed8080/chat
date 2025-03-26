//
// AddUserToUserGroupRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatDTO
import ChatCore

extension AddUserToUserGroupRequest: @retroactive ChatSendable, @retroactive SubjectProtocol {
    public var content: String? { nil }
    public var chatTypeCodeIndex: Index { typeCodeIndex }
    public var subjectId: Int { conversationId }
}
