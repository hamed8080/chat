//
// ArchiveThreadRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class ArchiveThreadRequestHandler {
    class func handle(_ req: ArchiveThreadRequest,
                      _ chat: Chat,
                      _ completion: @escaping CompletionType<Int>,
                      _ uniqueIdResult: UniqueIdResultType = nil)
    {
        chat.prepareToSendAsync(req: req,
                                clientSpecificUniqueId: req.uniqueId,
                                subjectId: req.threadId,
                                messageType: .archiveThread,
                                uniqueIdResult: uniqueIdResult) { response in
            completion(response.result as? Int, response.uniqueId, response.error)
        }
    }
}
