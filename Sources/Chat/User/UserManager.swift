//
// UserManager.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Additive
import Async
import ChatCore
import ChatDTO
import ChatExtensions
import ChatModels
import Foundation

final class UserManager: UserProtocol, InternalUserProtocol {
    public var userRetrycount = 0
    public let maxUserRetryCount = 5
    public var requestUserTimer: TimerProtocol = Timer()
    var chat: ChatInternalProtocol
    private var requests: [String: Any] = [:]

    init(chat: ChatInternalProtocol) {
        self.chat = chat
    }

    func set(_ request: RolesRequest) {
        chat.prepareToSendAsync(req: request, type: .setRuleToUser)
    }

    func set(_ request: AuditorRequest) {
        chat.prepareToSendAsync(req: request, type: .setRuleToUser)
    }

    func currentUserRoles(_ request: GeneralSubjectIdRequest) {
        chat.prepareToSendAsync(req: request, type: .getCurrentUserRoles)
        let roles = chat.cache?.userRole?.roles(request.subjectId)
        chat.delegate?.chatEvent(event: .user(.currentUserRoles(ChatResponse(uniqueId: request.uniqueId, result: roles, cache: true))))
    }

    func onCurrentUserRoles(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[Roles]> = asyncMessage.toChatResponse()
        let userRole = UserRole(threadId: response.subjectId, roles: response.result)
        chat.delegate?.chatEvent(event: .user(.currentUserRoles(response)))
        chat.cache?.userRole?.insert(models: [userRole])
    }

    func onSetRolesToUser(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[UserRole]> = asyncMessage.toChatResponse()
        chat.delegate?.chatEvent(event: .user(.setRolesToUser(response)))
        chat.cache?.userRole?.insert(models: response.result?.compactMap {
            $0.threadId = response.subjectId
            return $0
        } ?? [])
    }

    public func userInfo(_ request: UserInfoRequest) {
        chat.prepareToSendAsync(req: request, type: .userInfo)
        chat.cache?.user?.fetchCurrentUser { [weak self] userEntity in
            let response = ChatResponse(uniqueId: request.uniqueId, result: userEntity?.codable, cache: true)
            self?.chat.delegate?.chatEvent(event: .user(.user(response)))
        }
    }

    public func getUserForChatReady() {
        if chat.userInfo == nil {
            fetchUserInfo()
            requestUserTimer = requestUserTimer.scheduledTimer(interval: 5, repeats: true) { [weak self] _ in
                self?.fetchUserInfo()
            }
        } else {
            // it mean chat was connected before and reconnected again
            chat.delegate?.chatState(state: .chatReady, currentUser: chat.userInfo, error: nil)
            chat.asyncManager.sendQueuesOnReconnect()
            chat.asyncManager.sendPingTimer()
        }
    }

    internal func fetchUserInfo() {
        let req = UserInfoRequest()
        requests[req.uniqueId] = req
        userInfo(req)
    }

    private func onInternalUser(response: ChatResponse<User>) {
        guard let uniqueId = response.uniqueId, requests[uniqueId] != nil else { return }
        requests.removeValue(forKey: uniqueId)
        if let user = response.result {
            chat.cache?.user?.insert(user, isMe: true)
            chat.userInfo = user
            (chat as? ChatImplementation)?.state = .chatReady
            chat.delegate?.chatEvent(event: .user(.user(.init(result: user))))
            chat.delegate?.chatState(state: .chatReady, currentUser: user, error: nil)
            chat.asyncManager.sendQueuesOnReconnect()
            requestUserTimer.invalidateTimer()
        } else if userRetrycount < maxUserRetryCount {
            userRetrycount += 1
        } else {
            // reach to max retry
            requestUserTimer.invalidateTimer()
            let error = ChatError(type: .errorRaedyChat, message: "Reached max retry count!")
            let errorResponse = ChatResponse(result: Any?.none, error: error)
            chat.delegate?.chatEvent(event: .system(.error(errorResponse)))
        }
    }

    func onUserInfo(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<User> = asyncMessage.toChatResponse()
        if let user = response.result {
            chat.cache?.user?.insert(user)
        }
        onInternalUser(response: response)
        chat.delegate?.chatEvent(event: .system(.serverTime(.init(uniqueId: response.uniqueId, result: response.time, time: response.time))))
        chat.delegate?.chatEvent(event: .user(.user(response)))
    }

    func set(_ request: UpdateChatProfile) {
        chat.prepareToSendAsync(req: request, type: .setProfile)
    }

    func onSetProfile(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Profile> = asyncMessage.toChatResponse()
        chat.delegate?.chatEvent(event: .user(.setProfile(response)))
    }

    func remove(_ request: RolesRequest) {
        chat.prepareToSendAsync(req: request, type: .removeRoleFromUser)
    }

    func remove(_ request: AuditorRequest) {
        chat.prepareToSendAsync(req: request, type: .removeRoleFromUser)
    }

    func onRemveUserRoles(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[UserRole]> = asyncMessage.toChatResponse()
        chat.delegate?.chatEvent(event: .thread(.activity(.init(result: .init(time: response.time, threadId: response.subjectId)))))
        chat.delegate?.chatEvent(event: .user(.remove(response)))
    }

    func logOut() {
        let req = BareChatSendableRequest(uniqueId: UUID().uuidString)
        chat.prepareToSendAsync(req: req, type: .logout)
        chat.cache?.delete()
        if let docFoler = chat.cacheFileManager?.documentPath {
            chat.cacheFileManager?.deleteFolder(url: docFoler)
        }

        if let groupFoler = chat.cacheFileManager?.groupFolder {
            chat.cacheFileManager?.deleteFolder(url: groupFoler)
        }
        chat.dispose()
    }

    func send(_ request: SendStatusPingRequest) {
        chat.prepareToSendAsync(req: request, type: .statusPing)
    }

    func onStatusPing(_: AsyncMessage) {}
}
