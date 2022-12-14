//
// Chat+UserInfo.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    func requestUserInfo(_ req: UserInfoRequest,
                         _ completion: @escaping CompletionType<User>,
                         _ cacheResponse: CacheResponseType<User>? = nil,
                         _ uniqueIdResult: UniqueIdResultType? = nil)
    {
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
        cache.get(useCache: cacheResponse != nil, cacheType: .userInfo, completion: cacheResponse)
    }

    func getUserForChatReady() {
        if userInfo == nil {
            _ = requestUserTimer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] timer in
                self?.requestUserInfo(.init()) { (response: ChatResponse<User>) in
                    if let user = response.result {
                        self?.setUser(user: user)
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
        guard let chatMessage = asyncMessage.chatMessage else { return }
        delegate?.chatEvent(event: .system(.serverTime(chatMessage.time)))
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let user = try? JSONDecoder().decode(User.self, from: data) else { return }
        cache.write(cacheType: .userInfo(user))
        cache.save()
        guard let callback: CompletionType<User> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(ChatResponse(uniqueId: chatMessage.uniqueId, result: user))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .userInfo)
    }
}
