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
        cache.get(useCache: cacheResponse != nil, cacheType: .userInfo, completion: cacheResponse)
    }

    func getUserForChatReady() {
        if userInfo == nil {
            _ = requestUserTimer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] timer in
                self?.getUserInfo(.init()) { (response: ChatResponse<User>) in
                    if let user = response.result {
                        self?.userInfo = user
                        self?.delegate?.chatState(state: .chatReady, currentUser: user, error: nil)
                        self?.asyncManager.sendQueuesOnReconnect()
                        timer.invalidate()
                    } else if self?.userRetrycount ?? 0 < self?.maxUserRetryCount ?? 0 {
                        self?.userRetrycount += 1
                    } else {
                        // reach to max retry
                        timer.invalidate()
                        self?.delegate?.chatError(error: .init(code: .errorRaedyChat, message: response.error?.message))
                    }
                }
            }
        } else {
            // it mean chat was connected before and reconnected again
            delegate?.chatState(state: .chatReady, currentUser: userInfo, error: nil)
            asyncManager.sendQueuesOnReconnect()
            asyncManager.sendPingTimer()
        }
    }
}

// Response
extension Chat {
    func onUserInfo(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<User> = asyncMessage.toChatResponse()
        if let user = response.result {
            cache.write(cacheType: .userInfo(user))
            cache.save()
        }
        delegate?.chatEvent(event: .system(.serverTime(.init(uniqueId: response.uniqueId, result: response.time, time: response.time))))
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
