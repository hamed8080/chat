//
// UnPinThreadRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class UnPinThreadRequestHandler {
    class func handle(_ request: PinUnpinThreadRequest,
                      _ chat: Chat,
                      _ completion: @escaping CompletionType<Int>,
                      _ uniqueIdResult: UniqueIdResultType = nil)
    {
        chat.prepareToSendAsync(req: nil,
                                clientSpecificUniqueId: request.uniqueId,
                                subjectId: request.threadId,
                                messageType: .unpinThread,
                                uniqueIdResult: uniqueIdResult) { response in
            let pinResponse = response.result as? PinThreadResponse
            completion(pinResponse?.threadId, response.uniqueId, response.error)
        }
    }
}
