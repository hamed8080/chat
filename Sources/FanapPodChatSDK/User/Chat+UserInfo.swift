//
// Chat+UserInfo.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    /// Getting current user details.
    /// - Parameters:
    ///   - request: The request:
    ///   - completion: Response of the request.
    ///   - cacheResponse: cache response for the current user.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func getUserInfo(_ request: UserInfoRequest, completion: @escaping CompletionType<User>, cacheResponse: CacheResponseType<User>? = nil, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult, completion: completion)
    }

    func getUserForChatReady() {
        if userInfo == nil {
            requestUserTimer = requestUserTimer.scheduledTimer(interval: 2, repeats: true) { [weak self] _ in
                self?.onUserTimer()
            }
        } else {
            // it mean chat was connected before and reconnected again
            delegate?.chatState(state: .chatReady, currentUser: userInfo, error: nil)
            asyncManager.sendQueuesOnReconnect()
            asyncManager.sendPingTimer()
        }
    }

    internal func onUserTimer() {
        getUserInfo(.init()) { [weak self] (response: ChatResponse<User>) in
            self?.onUser(response: response)
        }
    }

    internal func onUser(response: ChatResponse<User>) {
        if let user = response.result {
            userInfo = user
            state = .chatReady
            delegate?.chatEvent(event: .user(.onUser(.init(result: user, typeCode: response.typeCode))))
            delegate?.chatState(state: .chatReady, currentUser: user, error: nil)
            asyncManager.sendQueuesOnReconnect()
            requestUserTimer.invalidateTimer()
        } else if userRetrycount < maxUserRetryCount {
            userRetrycount += 1
        } else {
            // reach to max retry
            requestUserTimer.invalidateTimer()
            delegate?.chatError(error: .init(type: .errorRaedyChat, message: response.error?.message))
        }
    }
}

// Response
extension Chat {
    func onUserInfo(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<User> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .system(.serverTime(.init(uniqueId: response.uniqueId, result: response.time, time: response.time, typeCode: response.typeCode))))
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
