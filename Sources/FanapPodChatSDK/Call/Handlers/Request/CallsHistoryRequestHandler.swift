//
// CallsHistoryRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class CallsHistoryRequestHandler {
    class func handle(_ req: CallsHistoryRequest,
                      _ chat: Chat,
                      _ completion: @escaping PaginationCompletionType<[Call]>,
                      _ uniqueIdResult: UniqueIdResultType = nil)
    {
        chat.prepareToSendAsync(req: req,
                                clientSpecificUniqueId: req.uniqueId,
                                messageType: .getCalls,
                                uniqueIdResult: uniqueIdResult) { response in
            let calls = response.result as? [Call]
            let pagination = PaginationWithContentCount(count: req.count, offset: req.offset, totalCount: response.contentCount)
            completion(calls, response.uniqueId, pagination, response.error)
        }
    }
}
