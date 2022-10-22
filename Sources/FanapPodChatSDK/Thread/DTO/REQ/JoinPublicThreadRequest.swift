//
// JoinPublicThreadRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public class JoinPublicThreadRequest: BaseRequest {
    public var threadName: String

    public init(threadName: String, uniqueId: String? = nil) {
        self.threadName = threadName
        super.init(uniqueId: uniqueId)
    }
}
