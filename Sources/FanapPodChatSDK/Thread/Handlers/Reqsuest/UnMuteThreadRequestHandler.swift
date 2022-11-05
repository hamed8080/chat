//
// UnMuteThreadRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class UnMuteThreadRequestHandler {
    class func handle(_ request: MuteUnmuteThreadRequest,
                      _ chat: Chat,
                      _ completion: @escaping CompletionType<Int>,
                      _ uniqueIdResult: UniqueIdResultType = nil)
    {
        chat.prepareToSendAsync(req: nil,
                                clientSpecificUniqueId: request.uniqueId,
                                subjectId: request.threadId,
                                messageType: .unmuteThread,
                                uniqueIdResult: uniqueIdResult) { response in
            let unmuteResponse = response.result as? UnMuteThreadResponse
            completion(unmuteResponse?.threadId, response.uniqueId, response.error)
        }
    }
}
