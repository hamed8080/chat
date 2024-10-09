//
// GeneralSubjectIdRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22

import ChatDTO
import ChatCore
import Foundation

extension GeneralSubjectIdRequest: ChatSendable, SubjectProtocol {}

public extension GeneralSubjectIdRequest {
    var subjectId: Int { _subjectId }
    var content: String? { nil }
    var chatTypeCodeIndex: Index { typeCodeIndex }
}
