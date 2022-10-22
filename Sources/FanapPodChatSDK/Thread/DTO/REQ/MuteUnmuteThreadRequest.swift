//
// MuteUnmuteThreadRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

public class MuteUnmuteThreadRequest: BaseRequest {
    public let threadId: Int

    public init(threadId: Int, uniqueId: String? = nil) {
        self.threadId = threadId
        super.init(uniqueId: uniqueId)
    }
}
