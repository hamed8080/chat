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
        let req = CDUser.fetchRequest()
        req.predicate = NSPredicate(format: "isMe == %@", NSNumber(booleanLiteral: true))
        let cachedUseInfo = (try? persistentManager.context?.fetch(req))?.first
        cacheResponse?(ChatResponse(uniqueId: request.uniqueId, result: cachedUseInfo?.codable))
    }

    func getUserForChatReady() {
        if userInfo == nil {
            requestUserTimer = requestUserTimer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
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
            cache?.user.insert([user], isMe: true)
            userInfo = user
            state = .chatReady
            delegate?.chatEvent(event: .user(.onUser(.init(result: user))))
            delegate?.chatState(state: .chatReady, currentUser: user, error: nil)
            asyncManager.sendQueuesOnReconnect()
            requestUserTimer.invalidate()
        } else if userRetrycount < maxUserRetryCount {
            userRetrycount += 1
        } else {
            // reach to max retry
            requestUserTimer.invalidate()
            delegate?.chatError(error: .init(type: .errorRaedyChat, message: response.error?.message))
        }
    }
}

// Response
extension Chat {
    func onUserInfo(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<User> = asyncMessage.toChatResponse()
        if let user = response.result {
            cache?.user.insert([user])
        }
        delegate?.chatEvent(event: .system(.serverTime(.init(uniqueId: response.uniqueId, result: response.time, time: response.time))))
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
