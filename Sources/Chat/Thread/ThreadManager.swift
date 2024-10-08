//
// ThreadManager.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Async
import ChatCache
import ChatCore
import ChatDTO
import ChatModels
import Foundation
import ChatExtensions

final class ThreadManager: ThreadProtocol {
    let chat: ChatInternalProtocol
    var cache: CacheManager? { chat.cache }
    var delegate: ChatDelegate? { chat.delegate }
    private var requests: [String: Any] = [:]
    let participant: ParticipantProtocol

    init(chat: ChatInternalProtocol) {
        self.chat = chat
        participant = ParticipantManager(chat: chat)
    }

    public func updateInfo(_ request: UpdateThreadInfoRequest) {
        let typeCode = request.toTypeCode(chat)
        if let image = request.threadImage {
            saveThreadImageToCashe(req: request)
            (chat.file as? ChatFileManager)?.upload(image, nil) { [weak self] _, fileMetaData, error in
                // send update thread Info with new file
                if let error = error {
                    let response = ChatResponse(uniqueId: request.uniqueId, result: Any?.none, error: error, typeCode: typeCode)
                    self?.delegate?.chatEvent(event: .system(.error(response)))

                } else {
                    self?.updateThreadInfo(request, fileMetaData)
                }
            }
        } else {
            // update directly without metadata
            updateThreadInfo(request, nil)
        }
    }

    func updateThreadInfo(_ req: UpdateThreadInfoRequest, _ fileMetaData: FileMetaData? = nil) {
        var req = req
        if let fileMetaData = fileMetaData {
            req.metadata = fileMetaData.jsonString
        }
        chat.prepareToSendAsync(req: req, type: .updateThreadInfo)
    }

    func saveThreadImageToCashe(req: UpdateThreadInfoRequest) {
        if let imageRequest = req.threadImage {
            cache?.fileQueue?.insert(models: [imageRequest.queueOfFileMessages])
        }
    }

    func onUpdateThreadInfo(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Conversation> = asyncMessage.toChatResponse()
        let copied = response.result
        delegate?.chatEvent(event: .thread(.updatedInfo(response)))
        cache?.conversation?.insert(models: [copied].compactMap { $0 })
    }

    func unreadCount(_ request: ThreadsUnreadCountRequest) {
        chat.prepareToSendAsync(req: request, type: .threadsUnreadCount)
        let typeCode = request.toTypeCode(chat)
        cache?.conversation?.threadsUnreadcount(request.threadIds) { [weak self] unreadCount in
            let response = ChatResponse(uniqueId: request.uniqueId, result: unreadCount, cache: true, typeCode: typeCode)
            self?.delegate?.chatEvent(event: .thread(.unreadCount(response)))
        }
    }

    func onThreadsUnreadCount(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[String: Int]> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .thread(.unreadCount(response)))
        cache?.conversation?.updateThreadsUnreadCount(response.result ?? [:])
    }

    func get(_ request: ThreadsRequest) {
        chat.coordinator.conversation.get(request)
    }

    func onThreads(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[Conversation]> = asyncMessage.toChatResponse(asyncManager: chat.asyncManager)
        chat.coordinator.conversation.onFetchedThreads(response)
    }

    func isNameAvailable(_ request: IsThreadNamePublicRequest) {
        chat.prepareToSendAsync(req: request, type: .isNameAvailable)
    }

    func onIsThreadNamePublic(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<PublicThreadNameAvailableResponse> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .thread(.isNameAvailable(response)))
    }

    /// Update when a contact user updates his name or the contacts updated and the name of the thread accordingly updated.
    func onThreadNameContactUpdated(_ asyncMessage: AsyncMessage) {
        var response: ChatResponse<Conversation> = asyncMessage.toChatResponse()
        let copied = response.result
        response.result?.id = response.subjectId
        delegate?.chatEvent(event: .thread(.updatedInfo(response)))
        cache?.conversation?.insert(models: [copied].compactMap { $0 })
    }

    func spam(_ request: GeneralSubjectIdRequest) {
        chat.prepareToSendAsync(req: request, type: .spamPvThread)
    }

    func onSpamThread(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Contact> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .thread(.spammed(response)))
    }

    /// Step 1: to leave safely
    func leaveSafely(_ request: SafeLeaveThreadRequest) {
        let currentUserRolseReq = request.generalRequest
        requests[request.uniqueId] = request
        chat.user.currentUserRoles(currentUserRolseReq)
    }

    /// Step 2: to leave safely
    func onCurrentUserRoles(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[Roles]> = asyncMessage.toChatResponse()
        guard let uniqueId = response.uniqueId, let request = requests[uniqueId] as? SafeLeaveThreadRequest else { return }
        let isAdmin = response.result?.contains(.threadAdmin) ?? false || response.result?.contains(.addRuleToUser) ?? false
        if isAdmin, let roles = response.result {
            let roleRequest = request.roleRequest(roles: roles)
            chat.user.set(roleRequest)
        } else {
            let chatError = ChatError(message: "Current User have no Permission to Change the ThreadAdmin", code: 6666, hasError: true)
            let response = ChatResponse(uniqueId: request.uniqueId, result: Any?.none, error: chatError, typeCode: response.typeCode)
            delegate?.chatEvent(event: .system(.error(response)))
        }
    }

    /// Step 3: to leave safely
    func onRoles(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<UserRole> = asyncMessage.toChatResponse()
        guard let uniqueId = response.uniqueId, let request = requests[uniqueId] as? SafeLeaveThreadRequest else { return }
        chat.prepareToSendAsync(req: request, type: .leaveThread)
    }

    func onUserRemovedFromThread(_ asyncMessage: AsyncMessage) {
        var response: ChatResponse<Int> = asyncMessage.toChatResponse()
        /// Do not remove this line. In the server response, there is no Int value when the user is removed by the admin of a thread.
        response.result = response.subjectId
        chat.coordinator.conversation.onDeleteConversation(response.subjectId ?? response.result)
        delegate?.chatEvent(event: .thread(.userRemoveFormThread(response)))
        cache?.conversation?.delete(response.result ?? -1)
    }

    func pin(_ request: GeneralSubjectIdRequest) {
        chat.prepareToSendAsync(req: request, type: .pinThread)
    }

    func unpin(_ request: GeneralSubjectIdRequest) {
        chat.prepareToSendAsync(req: request, type: .unpinThread)
    }

    func onPinUnPinThread(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Int> = asyncMessage.toChatResponse()
        let conversationId = response.result ?? -1
        let threadResponse = ChatResponse(uniqueId: response.uniqueId, result: Conversation(id: conversationId), subjectId: response.subjectId, time: response.time, typeCode: response.typeCode)
        let pinned = asyncMessage.chatMessage?.type == .pinThread
        chat.coordinator.conversation.onPinUnPin(pin: pinned, conversationId)
        delegate?.chatEvent(event: .thread(pinned ? .pin(threadResponse) : .unpin(threadResponse)))
        cache?.conversation?.pin(asyncMessage.chatMessage?.type == .pinThread, conversationId)
    }

    func mutual(_ request: MutualGroupsRequest) {
        requests[request.uniqueId] = request
        chat.prepareToSendAsync(req: request, type: .mutualGroups)
        let typeCode = request.toTypeCode(chat)
        cache?.mutualGroup?.mutualGroups(request.toBeUserVO.id ?? "") { [weak self] mutuals in
            let threads = mutuals.first?.conversations?.allObjects.compactMap { $0 as? CDConversation }.map { $0.codable() }
            let response = ChatResponse(uniqueId: request.uniqueId, result: threads, hasNext: threads?.count ?? 0 >= request.count, cache: true, typeCode: typeCode)
            self?.delegate?.chatEvent(event: .thread(.mutual(response)))
        }
    }

    func onMutalGroups(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[Conversation]> = asyncMessage.toChatResponse(asyncManager: chat.asyncManager)
        guard let uniqueId = response.uniqueId, let request = requests[uniqueId] as? MutualGroupsRequest else { return }
        let copies = response.result?.compactMap({$0}) ?? []
        cache?.mutualGroup?.insert(copies, idType: request.toBeUserVO.inviteeTypes, mutualId: request.toBeUserVO.id)
        delegate?.chatEvent(event: .thread(.mutual(response)))
    }

    func mute(_ request: GeneralSubjectIdRequest) {
        chat.prepareToSendAsync(req: request, type: .muteThread)
    }

    func unmute(_ request: GeneralSubjectIdRequest) {
        chat.prepareToSendAsync(req: request, type: .unmuteThread)
    }

    func onMuteUnMuteThread(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Int> = asyncMessage.toChatResponse()
        let conversationId = response.result ?? -1
        let mute = asyncMessage.chatMessage?.type == .muteThread
        chat.coordinator.conversation.onMuteOnMute(mute: mute, conversationId)
        delegate?.chatEvent(event: .thread(mute ? .mute(response) : .unmute(response)))
        cache?.conversation?.mute(asyncMessage.chatMessage?.type == .muteThread, response.subjectId ?? -1)
    }

    func leave(_ request: LeaveThreadRequest) {
        chat.prepareToSendAsync(req: request, type: .leaveThread)
    }

    func onLeaveThread(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<User> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .thread(.left(response)))
        cache?.participant?.delete([Participant(id: response.result?.id)], response.subjectId ?? -1)
        if response.result?.id == chat.userInfo?.id, let threadId = response.subjectId {
            chat.coordinator.conversation.onDeleteConversation(threadId)
            cache?.conversation?.delete(threadId)
        }
    }

    func onLastSeenUpdate(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<LastSeenMessageResponse> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .thread(.lastSeenMessageUpdated(response)))
        if let threadId = response.result?.id, let unreadCount = response.result?.unreadCount {
            cache?.conversation?.seen(threadId: threadId,
                                      lastSeenMessageId: response.result?.lastSeenMessageId ?? -1,
                                      lastSeenMessageTime: response.result?.lastSeenMessageTime,
                                      lastSeenMessageNanos: response.result?.lastSeenMessageNanos)
            cache?.conversation?.updateThreadsUnreadCount(["\(threadId)": unreadCount])           
        }
    }

    func join(_ request: JoinPublicThreadRequest) {
        chat.prepareToSendAsync(req: request, type: .joinThread)
    }

    func onJoinThread(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Conversation> = asyncMessage.toChatResponse()
        let copied = response.result
        chat.coordinator.conversation.onJoined(conversation: copied)
        delegate?.chatEvent(event: .thread(.joined(response)))
    }

    func delete(_ request: GeneralSubjectIdRequest) {
        chat.prepareToSendAsync(req: request, type: .deleteThread)
    }

    func onDeleteThread(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Participant> = asyncMessage.toChatResponse()
        chat.coordinator.conversation.onDeleteConversation(response.subjectId)
        delegate?.chatEvent(event: .thread(.deleted(response)))
        cache?.conversation?.delete(response.subjectId ?? -1)
    }

    func create(_ request: CreateThreadRequest) {
        chat.prepareToSendAsync(req: request, type: .createThread)
    }

    func create(_ request: CreateThreadWithMessage) {
        chat.prepareToSendAsync(req: request, type: .createThread)
    }

    func create(_ request: CreateThreadRequest, _ textMessage: SendTextMessageRequest) {
        requests[request.uniqueId] = textMessage
        chat.prepareToSendAsync(req: request, type: .createThread)
    }

    func create(_ request: CreateThreadRequest, _ textMessage: SendTextMessageRequest, _ uploadFile: UploadFileRequest) {
        requests[request.uniqueId] = textMessage
        requests[textMessage.uniqueId] = uploadFile
        chat.prepareToSendAsync(req: request, type: .createThread)
    }

    func onCreateThread(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Conversation> = asyncMessage.toChatResponse()
        let copied = response.result
        chat.coordinator.conversation.onCreateConversation(copied)
        delegate?.chatEvent(event: .thread(.created(response)))
        cache?.conversation?.insert(models: [copied].compactMap { $0 })
        sendTextMessage(response)
    }

    /// Create thread and Send a text message.
    private func sendTextMessage(_ response: ChatResponse<Conversation>) {
        if let uniqueId = response.uniqueId, let request = requests[uniqueId] as? SendTextMessageRequest {
            chat.message.send(request)
        }
    }

    /// Create thread and Send a text message and then upload a file.
    func onNewMessage(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Message> = asyncMessage.toChatResponse()
        let copied = response.result
        chat.coordinator.conversation.onNewMessage(copied)
        if let uniqueId = response.uniqueId, let request = requests[uniqueId] as? UploadFileRequest {
            chat.file.upload(request)
        }
    }

    func close(_ request: GeneralSubjectIdRequest) {
        chat.prepareToSendAsync(req: request, type: .closeThread)
    }

    func onCloseThread(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Int> = asyncMessage.toChatResponse()
        let newResponse = ChatResponse<Int>(uniqueId: response.uniqueId,
                                            result: response.subjectId,
                                            error: response.error,
                                            subjectId: response.subjectId,
                                            time: response.time,
                                            typeCode: response.typeCode)
        chat.coordinator.conversation.onClosed(newResponse.result)
        delegate?.chatEvent(event: .thread(.closed(newResponse)))
        cache?.conversation?.close(true, newResponse.result ?? -1)
    }

    func changeType(_ request: ChangeThreadTypeRequest) {
        chat.prepareToSendAsync(req: request, type: .changeThreadType)
    }

    func onChangeThreadType(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Conversation> = asyncMessage.toChatResponse()
        let copied = response.result
        cache?.conversation?.changeThreadType(copied?.id ?? -1, copied?.type ?? .unknown)
        chat.coordinator.conversation.onChangeConversationType(copied)
        delegate?.chatEvent(event: .thread(.changedType(response)))
    }

    func archive(_ request: GeneralSubjectIdRequest) {
        chat.prepareToSendAsync(req: request, type: .archiveThread)
    }

    func unarchive(_ request: GeneralSubjectIdRequest) {
        chat.prepareToSendAsync(req: request, type: .unarchiveThread)
    }

    func onArchiveUnArchiveThread(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Int> = asyncMessage.toChatResponse()
        let archived = asyncMessage.chatMessage?.type == .archiveThread
        cache?.conversation?.archive(archived, response.subjectId ?? -1)
        chat.coordinator.conversation.onArchiveUnArchive(archive: archived, id: response.result)
        delegate?.chatEvent(event: .thread(archived ? .archive(response) : .unArchive(response)))
    }

    func allUnreadCount(_ request: AllThreadsUnreadCountRequest) {
        chat.prepareToSendAsync(req: request, type: .allUnreadMessageCount)
        let typeCode = request.toTypeCode(chat)
        cache?.conversation?.allUnreadCount { [weak self] allUnreadCount in
            let response = ChatResponse(uniqueId: request.uniqueId, result: allUnreadCount, cache: true, typeCode: typeCode)
            self?.delegate?.chatEvent(event: .thread(.allUnreadCount(response)))
        }
    }

    func onUnreadMessageCount(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Int> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .thread(.allUnreadCount(response)))
    }

    func lastAction(_ request: LastActionInConversationRequest) {
        chat.prepareToSendAsync(req: request, type: .lastActionInThread)
    }

    func onLastActionInThread(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[LastActionInConversation]> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .thread(.lastActions(response)))
    }
}
