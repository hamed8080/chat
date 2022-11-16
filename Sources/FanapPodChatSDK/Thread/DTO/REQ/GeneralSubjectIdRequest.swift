//
// GeneralSubjectIdRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public class GeneralSubjectIdRequest: UniqueIdManagerRequest, ChatSnedable, SubjectProtocol {
    var chatMessageType: ChatMessageVOTypes = .unknown
    var subjectId: Int
    var content: String?

    public init(subjectId: Int, uniqueId: String? = nil) {
        self.subjectId = subjectId
        super.init(uniqueId: uniqueId)
    }
}
