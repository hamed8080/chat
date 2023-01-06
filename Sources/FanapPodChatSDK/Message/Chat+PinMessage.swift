//
// Chat+PinMessage.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import FanapPodAsyncSDK
import Foundation

// Request
public extension Chat {
    /// Pin a message inside a thread.
    /// - Parameters:
    ///   - request: The request that contains messageId.
    ///   - completion: The response of pinned thread.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func pinMessage(_ request: PinUnpinMessageRequest, completion: @escaping CompletionType<PinMessage>, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult, completion: completion)
    }

    /// UnPin a message inside a thread.
    /// - Parameters:
    ///   - request: The request that contains messageId.
    ///   - completion: The response of unpinned thread.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func unpinMessage(_ request: PinUnpinMessageRequest, completion: @escaping CompletionType<PinMessage>, uniqueIdResult: UniqueIdResultType? = nil) {
        request.chatMessageType = .unpinMessage
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onPinUnPinMessage(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<PinMessage> = asyncMessage.toChatResponse(context: persistentManager.context)
        if asyncMessage.chatMessage?.type == .pinMessage, let message = response.result {
            delegate?.chatEvent(event: .thread(.messagePin(response)))
            cache?.write(cacheType: .pinMessage(message, response.subjectId))
        } else if let message = response.result {
            delegate?.chatEvent(event: .thread(.messageUnpin(response)))
            cache?.write(cacheType: .unpinMessage(message, response.subjectId))
        }
        cache?.save()
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
