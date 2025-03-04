//
// UserManager.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Additive
import Async
import ChatCore
import ChatDTO
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
        Task {
            await emitEvent(.user(.currentUserRoles(chat.cachedUserRoles(request))))
        }
    }

    func onCurrentUserRoles(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[Roles]> = asyncMessage.toChatResponse()
        let userRole = UserRole(threadId: response.subjectId, roles: response.result)
        emitEvent(.user(.currentUserRoles(response)))
        chat.cache?.userRole?.insert(models: [userRole])
    }

    func onSetRolesToUser(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[UserRole]> = asyncMessage.toChatResponse()
        emitEvent(.user(.setRolesToUser(response)))
        chat.cache?.userRole?.insert(models: response.fixUserRolesThreadId())
    }

    public func userInfo(_ request: UserInfoRequest) {
        chat.prepareToSendAsync(req: request, type: .userInfo)
        let typeCode = request.toTypeCode(chat)
        let userCache = chat.cache?.user
        Task { @MainActor in
            if let userEntity = userCache?.fetchCurrentUser() {
                emitEvent(event: userEntity.toEvent(request, typeCode))
            }
        }
    }

    public func getUserForChatReady() {
        if chat.userInfo == nil {
            fetchUserInfo()
            requestUserTimer = requestUserTimer.scheduledTimer(interval: 5, repeats: true) { [weak self] _ in
                Task { @ChatGlobalActor in
                    self?.fetchUserInfo()
                }
            }
        } else {
            // it mean chat was connected before and reconnected again
            chat.delegate?.chatState(state: .chatReady, currentUser: chat.userInfo, error: nil)
            chat.asyncManager.sendQueuesOnReconnect()
            chat.asyncManager.schedulePingTimer()
        }
    }

    internal func fetchUserInfo() {
        if chat.state != .chatReady {
            let req = UserInfoRequest()
            requests[req.uniqueId] = req
            userInfo(req)
        } else {
            requestUserTimer.invalidateTimer()
        }
    }

    private func onInternalUser(response: ChatResponse<User>) async {
        guard let uniqueId = response.uniqueId, requests[uniqueId] != nil else { return }
        requests.removeValue(forKey: uniqueId)
        if let user = response.result {
            await chat.cache?.user?.insertOnMain(user, isMe: true)
            chat.userInfo = user
            (chat as? ChatImplementation)?.state = .chatReady
            emitEvent(.user(.user(.init(result: user, typeCode: response.typeCode))))
            chat.delegate?.chatState(state: .chatReady, currentUser: user, error: nil)
            chat.asyncManager.sendQueuesOnReconnect()
            requestUserTimer.invalidateTimer()
        } else if userRetrycount < maxUserRetryCount {
            userRetrycount += 1
        } else {
            // reach to max retry
            requestUserTimer.invalidateTimer()
            let error = ChatError(type: .errorRaedyChat, message: "Reached max retry count!")
            let errorResponse = ChatResponse<Sendable>(error: error, typeCode: response.typeCode)
            emitEvent(.system(.error(errorResponse)))
        }
    }

    func onUserInfo(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<User> = asyncMessage.toChatResponse()
        Task {
            await onInternalUser(response: response)
        }
        emitEvent(.system(.serverTime(.init(userInfoRes: response))))
    }

    func set(_ request: UpdateChatProfile) {
        chat.prepareToSendAsync(req: request, type: .setProfile)
    }

    func onSetProfile(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Profile> = asyncMessage.toChatResponse()
        emitEvent(.user(.setProfile(response)))
    }

    func remove(_ request: RolesRequest) {
        chat.prepareToSendAsync(req: request, type: .removeRoleFromUser)
    }

    func remove(_ request: AuditorRequest) {
        chat.prepareToSendAsync(req: request, type: .removeRoleFromUser)
    }

    func onRemveUserRoles(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[UserRole]> = asyncMessage.toChatResponse()
        emitEvent(.user(.remove(response)))
    }

    func logOut() {
        let req = BareChatSendableRequest(uniqueId: UUID().uuidString)
        chat.prepareToSendAsync(req: req, type: .logout)
        chat.cache?.delete()
        chat.deleteDocumentFolders()
        Task {
            await chat.dispose()
        }
    }

    func send(_ request: SendStatusPingRequest) {
        chat.prepareToSendAsync(req: request, type: .statusPing)
    }

    func onStatusPing(_: AsyncMessage) {}
    
    private nonisolated func emitEvent(event: ChatEventType) {
        Task { @ChatGlobalActor [weak self] in
            self?.emitEvent(event)
        }
    }
    
    private func emitEvent(_ event: ChatEventType) {
        chat.delegate?.chatEvent(event: event)
    }
}
