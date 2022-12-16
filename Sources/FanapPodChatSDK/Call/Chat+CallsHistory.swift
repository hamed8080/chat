//
// Chat+CallsHistory.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    func requestCallsHistory(_ req: CallsHistoryRequest, _ completion: @escaping CompletionType<[Call]>, _ uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult) { (response: ChatResponse<[Call]>) in
            let pagination = PaginationWithContentCount(count: req.count, offset: req.offset, totalCount: response.contentCount)
            completion(ChatResponse(uniqueId: response.uniqueId, result: response.result, error: response.error, pagination: pagination))
        }
    }
}

// Response
extension Chat {
    func onCallsHistory(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let callback: CompletionType<[Call]> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let calls = try? JSONDecoder().decode([Call].self, from: data) else { return }
        callback(.init(uniqueId: chatMessage.uniqueId, result: calls, contentCount: chatMessage.contentCount ?? 0))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .getCalls)
    }
}
