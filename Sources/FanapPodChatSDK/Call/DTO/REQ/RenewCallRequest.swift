//
// RenewCallRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public class RenewCallRequest: UniqueIdManagerRequest, ChatSnedable, SubjectProtocol {
    let invitess: [Invitee]
    let callId: Int
    var subjectId: Int { callId }
    var content: String? { invitess.convertCodableToString() }
    var chatMessageType: ChatMessageVOTypes = .renewCallRequest

    public init(invitees: [Invitee], callId: Int, uniqueId: String? = nil) {
        invitess = invitees
        self.callId = callId
        super.init(uniqueId: uniqueId)
    }
}
