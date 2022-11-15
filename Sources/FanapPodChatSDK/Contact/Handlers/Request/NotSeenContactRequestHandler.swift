//
// NotSeenContactRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class NotSeenContactRequestHandler {
    class func handle(_ req: NotSeenDurationRequest,
                      _ chat: Chat,
                      _ completion: @escaping CompletionType<[UserLastSeenDuration]>,
                      _ uniqueIdResult: UniqueIdResultType? = nil)
    {
        chat.prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult) { response in
            let contactNotSeenDusrationresponse = response.result as? ContactNotSeenDurationRespoonse
            completion(contactNotSeenDusrationresponse?.notSeenDuration, response.uniqueId, response.error)
        }
    }
}
