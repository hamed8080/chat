//
// RemoveTagParticipantsRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public class RemoveTagParticipantsRequest: BaseRequest {
    public var tagId: Int
    public var tagParticipants: [TagParticipant]

    public init(tagId: Int, tagParticipants: [TagParticipant], uniqueId: String? = nil) {
        self.tagId = tagId
        self.tagParticipants = tagParticipants
        super.init(uniqueId: uniqueId)
    }
}
