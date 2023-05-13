//
// ChatImplementation+CancelMessage.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Async
import ChatCore
import ChatDTO
import ChatModels
import Foundation

public extension ChatImplementation {
    /// Cancel a message send.
    /// - Parameters:
    ///   - uniqueId: The uniqueId of a message to cancel and delete from cache.
    ///   - completion: The result of cancelation.
    func cancelMessage(uniqueId: String, completion: @escaping CompletionTypeNoneDecodeable<Bool>) {
        cache?.deleteQueues(uniqueIds: [uniqueId])
        manageUpload(uniqueId: uniqueId, action: .cancel) { _, state in
            completion(ChatResponse(uniqueId: uniqueId, result: state))
        }
        completion(ChatResponse(uniqueId: uniqueId, result: true))
    }
}
