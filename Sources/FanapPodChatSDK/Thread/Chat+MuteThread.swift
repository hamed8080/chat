//
// Chat+MuteThread.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    func requestMuteThread(_ req: GeneralSubjectIdRequest, _ completion: @escaping CompletionType<Int>, _ uniqueIdResult: UniqueIdResultType? = nil) {
        req.chatMessageType = .muteThread
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
    }

    func requestUnMuteThread(_ req: GeneralSubjectIdRequest, _ completion: @escaping CompletionType<Int>, _ uniqueIdResult: UniqueIdResultType? = nil) {
        req.chatMessageType = .unmuteThread
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onMuteUnMuteThread(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let threadId = try? JSONDecoder().decode(Int.self, from: data) else { return }
        if chatMessage.type == .muteThread {
            delegate?.chatEvent(event: .thread(.threadMute(threadId: threadId)))
        } else if chatMessage.type == .unmuteThread {
            delegate?.chatEvent(event: .thread(.threadUnmute(threadId: threadId)))
        }
        let resposne = MuteThreadResponse(threadId: threadId)
        cache.write(cacheType: .muteUnmuteThread(threadId))
        cache.save()
        guard let callback: CompletionType<MuteThreadResponse> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(ChatResponse(uniqueId: chatMessage.uniqueId, result: resposne))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .muteThread)
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .unmuteThread)
    }
}
