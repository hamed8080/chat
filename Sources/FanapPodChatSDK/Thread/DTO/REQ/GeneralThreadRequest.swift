//
// GeneralThreadRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public class GeneralThreadRequest: BaseRequest, ChatSnedable, SubjectProtocol {
    var chatMessageType: ChatMessageVOTypes = .unknown
    var subjectId: Int? { threadId }
    var content: String?
    var threadId: Int

    public init(threadId: Int, uniqueId: String? = nil) {
        self.threadId = threadId
        super.init(uniqueId: uniqueId)
    }
}
