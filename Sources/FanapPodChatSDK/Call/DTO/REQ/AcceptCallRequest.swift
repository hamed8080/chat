//
// AcceptCallRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public class AcceptCallRequest: UniqueIdManagerRequest, ChatSendable, SubjectProtocol {
    let client: SendClient
    let callId: Int
    var content: String? { client.convertCodableToString() }
    var subjectId: Int { callId }
    var chatMessageType: ChatMessageVOTypes = .acceptCall

    public init(callId: Int, client: SendClient, uniqueId: String? = nil) {
        self.callId = callId
        self.client = client
        super.init(uniqueId: uniqueId)
    }
}
