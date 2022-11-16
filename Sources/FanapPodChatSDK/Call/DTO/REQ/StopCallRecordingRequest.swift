//
// StopCallRecordingRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public class StopCallRecordingRequest: UniqueIdManagerRequest, ChatSnedable, SubjectProtocol {
    let callId: Int
    var subjectId: Int? { callId }
    var chatMessageType: ChatMessageVOTypes = .stopRecording
    var content: String?

    public init(callId: Int, uniqueId: String? = nil) {
        self.callId = callId
        super.init(uniqueId: uniqueId)
    }
}
