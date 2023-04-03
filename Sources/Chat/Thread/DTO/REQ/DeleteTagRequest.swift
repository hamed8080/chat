//
// DeleteTagRequest.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/19/22

import Foundation
public final class DeleteTagRequest: UniqueIdManagerRequest, ChatSendable, SubjectProtocol {
    public var id: Int
    var subjectId: Int { id }
    var chatMessageType: ChatMessageVOTypes = .deleteTag
    var content: String?

    public init(id: Int, uniqueId: String? = nil) {
        self.id = id
        super.init(uniqueId: uniqueId)
    }
}
