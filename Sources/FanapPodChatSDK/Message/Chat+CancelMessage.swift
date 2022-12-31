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
    ///   - request: The uniqueId of a message.
    ///   - completion: The result of cancelation.
    func cancelMessage(_ request: CancelMessageRequest, completion: @escaping CompletionTypeNoneDecodeable<Bool>) {
        if config.enableCache == true {
            if let uniqueId = request.textMessageUniqueId {
                cache?.write(cacheType: .deleteWaitTextMessage(uniqueId))
                completion(ChatResponse(uniqueId: uniqueId, result: true))
            } else if let uniqueId = request.editMessageUniqueId {
                cache?.write(cacheType: .deleteEditTextMessage(uniqueId))
                completion(ChatResponse(uniqueId: uniqueId, result: true))
            } else if let uniqueId = request.forwardMessageUniqueId {
                cache?.write(cacheType: .deleteForwardMessage(uniqueId))
                completion(ChatResponse(uniqueId: uniqueId, result: true))
            } else if let uniqueId = request.fileMessageUniqueId {
                cache?.write(cacheType: .deleteWaitFileMessage(uniqueId))
                completion(ChatResponse(uniqueId: uniqueId, result: true))
            } else if let uniqueId = request.uploadFileUniqueId {
                manageUpload(uniqueId: uniqueId, action: .cancel) { _, state in
                    completion(ChatResponse(uniqueId: uniqueId, result: state))
                }
            } else if let uniqueId = request.uploadImageUniqueId {
                manageUpload(uniqueId: uniqueId, action: .cancel) { _, state in
                    completion(ChatResponse(uniqueId: uniqueId, result: state))
                }
            }
        }
    }
}
