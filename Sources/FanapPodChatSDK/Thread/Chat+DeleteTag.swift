//
// Chat+DeleteTag.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    func requestDeleteTag(_ req: DeleteTagRequest, _ completion: @escaping CompletionType<Tag>, _ uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onDeleteTag(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let tag = try? JSONDecoder().decode(Tag.self, from: data) else { return }
        delegate?.chatEvent(event: .tag(.deleteTag(tag)))
        cache.write(cacheType: .deleteTag(tag))
        cache.save()
        guard let callback: CompletionType<Tag> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(ChatResponse(uniqueId: chatMessage.uniqueId, result: tag))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .deleteTag)
    }
}
