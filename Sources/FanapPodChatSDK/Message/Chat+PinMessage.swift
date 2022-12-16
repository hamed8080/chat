//
// Chat+PinMessage.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    func requestPinUnPinMessage(_ req: PinUnpinMessageRequest, _ completion: @escaping CompletionType<PinUnpinMessage>, _ uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onPinUnPinMessage(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let pinResponse = try? JSONDecoder().decode(PinUnpinMessage.self, from: data) else { return }
        if chatMessage.type == .pinMessage {
            delegate?.chatEvent(event: .thread(.messagePin(threadId: chatMessage.subjectId, pinResponse)))
            cache.write(cacheType: .pinMessage(pinResponse, chatMessage.subjectId))
        } else {
            delegate?.chatEvent(event: .thread(.messageUnpin(threadId: chatMessage.subjectId, pinResponse)))
            cache.write(cacheType: .unpinMessage(pinResponse, chatMessage.subjectId))
        }
        cache.save()
        guard let callback: CompletionType<PinUnpinMessage> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(ChatResponse(uniqueId: chatMessage.uniqueId, result: pinResponse))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .pinMessage)
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .unpinMessage)
    }
}
