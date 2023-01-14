//
// Chat+CancelMessage.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import FanapPodAsyncSDK
import Foundation

public extension Chat {
    /// Cancel a message send.
    /// - Parameters:
    ///   - uniqueId: The uniqueId of a message to cancel and delete from cache.
    ///   - completion: The result of cancelation.
    func cancelMessage(uniqueId: String, completion: @escaping CompletionTypeNoneDecodeable<Bool>) {
        deleteQueues(uniqueIds: [uniqueId])
        manageUpload(uniqueId: uniqueId, action: .cancel) { _, state in
            completion(ChatResponse(uniqueId: uniqueId, result: state))
        }
        completion(ChatResponse(uniqueId: uniqueId, result: true))
    }
}
