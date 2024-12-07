//
// EditTagRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22

import ChatDTO
import ChatCore
import Foundation

extension EditTagRequest: @retroactive ChatSendable, @retroactive SubjectProtocol {}

public extension EditTagRequest {
    var subjectId: Int { id }
    var content: String? { jsonString }
    var chatTypeCodeIndex: Index { typeCodeIndex }
}
