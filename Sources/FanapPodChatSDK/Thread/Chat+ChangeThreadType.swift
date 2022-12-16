//
// Chat+ChangeThreadType.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    func requestChangeThreadType(_ req: ChangeThreadTypeRequest, _ completion: @escaping CompletionType<Conversation>, _ uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onChangeThreadType(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        if config.enableCache, let threadId = chatMessage.subjectId {
            delegate?.chatEvent(event: .thread(.threadRemovedFrom(threadId: threadId)))
            cache.write(cacheType: .deleteThreads([threadId]))
        }
        if let callback: CompletionType<Conversation> = callbacksManager.getCallBack(chatMessage.uniqueId), let data = chatMessage.content?.data(using: .utf8) {
            let thread = try? JSONDecoder().decode(Conversation.self, from: data)
            callback(ChatResponse(uniqueId: chatMessage.uniqueId, result: thread))
        }
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .changeThreadType)
    }
}
