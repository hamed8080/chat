//
// Chat+PinThread.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    func requestPinThread(_ req: GeneralSubjectIdRequest, _ completion: @escaping CompletionType<Int>, _ uniqueIdResult: UniqueIdResultType? = nil) {
        req.chatMessageType = .pinThread
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
    }

    func requestUnPinThread(_ req: GeneralSubjectIdRequest, _ completion: @escaping CompletionType<Int>, _ uniqueIdResult: UniqueIdResultType? = nil) {
        req.chatMessageType = .unpinThread
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onPinUnPinThread(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let threadId = try? JSONDecoder().decode(Int.self, from: data) else { return }
        if chatMessage.type == .pinThread {
            delegate?.chatEvent(event: .thread(.threadPin(threadId: threadId)))
        } else if chatMessage.type == .unpinThread {
            delegate?.chatEvent(event: .thread(.threadUnpin(threadId: threadId)))
        }
        let resposne = PinThreadResponse(threadId: threadId)
        cache.write(cacheType: .pinUnpinThread(threadId))
        cache.save()
        guard let callback: CompletionType<PinThreadResponse> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(ChatResponse(uniqueId: chatMessage.uniqueId, result: resposne))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .pinThread)
    }
}
