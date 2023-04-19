//
// GeneralSubjectIdRequest.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/19/22

import Foundation
import ChatCore

public final class GeneralSubjectIdRequest: UniqueIdManagerRequest, ChatSendable, SubjectProtocol {
    public var chatMessageType: ChatMessageVOTypes = .unknown
    public var subjectId: Int
    public var content: String?

    public init(subjectId: Int, uniqueId: String? = nil) {
        self.subjectId = subjectId
        super.init(uniqueId: uniqueId)
    }
}
