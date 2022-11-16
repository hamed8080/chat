//
// MessagSeenByUsersRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class MessagSeenByUsersRequestHandler {
    class func handle(_ req: MessageSeenByUsersRequest,
                      _ chat: Chat,
                      _ completion: @escaping PaginationCompletionType<[Participant]>,
                      _ uniqueIdResult: UniqueIdResultType? = nil)
    {
        chat.prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult) { response in
            let pagination = PaginationWithContentCount(count: req.count, offset: req.offset, totalCount: response.contentCount)
            completion(response.result as? [Participant], response.uniqueId, pagination, response.error)
        }
    }
}
