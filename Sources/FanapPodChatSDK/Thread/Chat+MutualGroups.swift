//
// Chat+MutualGroups.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    func requestMutualGroups(_ req: MutualGroupsRequest,
                             _ completion: @escaping CompletionType<[Conversation]>,
                             _ cacheResponse: CacheResponseType<[Conversation]>? = nil,
                             _ uniqueIdResult: UniqueIdResultType? = nil)
    {
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult) { [weak self] (response: ChatResponse<[Conversation]>) in
            let pagination = PaginationWithContentCount(count: req.count, offset: req.offset, totalCount: response.contentCount)
            completion(ChatResponse(uniqueId: response.uniqueId, result: response.result, error: response.error, pagination: pagination))

            // insert to mutual cache only for this method beacuse we need request and id and idType to be cache
            if let conversations = response.result {
                self?.cache.write(cacheType: .mutualGroups(conversations, req))
                self?.cache.save()
            }
        }

        cache.get(useCache: cacheResponse != nil, cacheType: .getMutualGroups(req)) { (response: ChatResponse<[Conversation]>) in
            let pagination = PaginationWithContentCount(count: req.count, offset: req.offset, totalCount: CMMutualGroup.crud.getTotalCount())
            cacheResponse?(ChatResponse(uniqueId: response.uniqueId, result: response.result, error: response.error, pagination: pagination))
        }
    }
}

// Response
extension Chat {
    func onMutalGroups(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let mutalGroups = try? JSONDecoder().decode([Conversation].self, from: data) else { return }
        guard let callback: CompletionType<[Conversation]> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(ChatResponse(uniqueId: chatMessage.uniqueId, result: mutalGroups))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .mutualGroups)
    }
}
