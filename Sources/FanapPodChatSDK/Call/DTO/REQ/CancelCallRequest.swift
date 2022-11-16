//
// CancelCallRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public class CancelCallRequest: UniqueIdManagerRequest, ChatSnedable, SubjectProtocol {
    let call: Call
    var chatMessageType: ChatMessageVOTypes = .cancelCall
    var subjectId: Int? { call.id }
    var content: String? { call.convertCodableToString() }

    public init(call: Call, uniqueId: String? = nil) {
        self.call = call
        super.init(uniqueId: uniqueId)
    }
}
