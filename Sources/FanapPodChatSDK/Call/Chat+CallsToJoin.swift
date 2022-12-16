//
// Chat+CallsToJoin.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    func requestJoinCall(_ req: GetJoinCallsRequest, _ completion: @escaping CompletionType<[Call]>, _ uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onJoinCalls(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let callsToJoin = try? JSONDecoder().decode([Call].self, from: data) else { return }
        guard let callback: CompletionType<[Call]> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        delegate?.chatEvent(event: .call(.callsToJoin(callsToJoin)))
        callback(.init(uniqueId: chatMessage.uniqueId, result: callsToJoin))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .getCallsToJoin)
    }
}
