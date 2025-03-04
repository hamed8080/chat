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
            (chat.file as? ChatFileManager)?.upload(image, nil) { [weak self] resp in
                Task {
                    await self?.onUploadProfileImage(resp, request, typeCode)
                }
            }
        } else {
            // update directly without metadata
            updateThreadInfo(request, nil)
        }
    }
    
    private func onUploadProfileImage(_ resp: UploadResult, _ request: UpdateThreadInfoRequest, _ typeCode: String?) {
        // send update thread Info with new file
        if let error = resp.error {
            let response = ChatResponse<Sendable>(uniqueId: request.uniqueId, error: error, typeCode: typeCode)
            emitEvent(.system(.error(response)))
        } else {
            updateThreadInfo(request, resp.metaData)
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
        emitEvent(.thread(.updatedInfo(response)))
        cache?.conversation?.insert(models: [response.result].compactMap { $0 })
    }

    func unreadCount(_ request: ThreadsUnreadCountRequest) {
        chat.prepareToSendAsync(req: request, type: .threadsUnreadCount)
        let typeCode = request.toTypeCode(chat)
        cache?.conversation?.threadsUnreadcount(request.threadIds) { [weak self] unreadCount in
            self?.emitEvent(event: unreadCount.toCachedUnreadCountEvent(request, typeCode))
        }
    }

    func onThreadsUnreadCount(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[String: Int]> = asyncMessage.toChatResponse()
        emitEvent(.thread(.unreadCount(response)))
        Task {
            await cache?.conversation?.updateThreadsUnreadCount(response.result ?? [:])
        }
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
        emitEvent(.thread(.isNameAvailable(response)))
    }

    /// Update once the user edit a contact or add the user as a contact.
    func onThreadNameContactUpdated(_ asyncMessage: AsyncMessage) {
        var response: ChatResponse<Conversation> = asyncMessage.toChatResponse()
        response.result?.id = response.subjectId
        emitEvent(.thread(.updatedInfo(response)))
        if let threadId = response.subjectId {
            cache?.conversation?.updateTitle(id: threadId, title: response.result?.title)
        }
    }

    func spam(_ request: GeneralSubjectIdRequest) {
        chat.prepareToSendAsync(req: request, type: .spamPvThread)
    }

    func onSpamThread(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Contact> = asyncMessage.toChatResponse()
        emitEvent(.thread(.spammed(response)))
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
        let tuple = response.safeLeaveRole(requests)
        if let roleRequest = tuple.roleRequest {
            chat.user.set(roleRequest)
        } else if let request = tuple.request {
            emitEvent(toCurrentUserRoleErrorEvent(request, typeCode: response.typeCode))
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
        emitEvent(.thread(.userRemoveFormThread(response)))
        cache?.conversation?.delete(response.result ?? -1)
    }

    func pin(_ request: GeneralSubjectIdRequest) {
        chat.prepareToSendAsync(req: request, type: .pinThread)
    }

    func unpin(_ request: GeneralSubjectIdRequest) {
        chat.prepareToSendAsync(req: request, type: .unpinThread)
    }

    func onPinUnPinThread(_ asyncMessage: AsyncMessage) {
        let tuple = asyncMessage.pinUnpinTuple()
        chat.coordinator.conversation.onPinUnPin(pin: tuple.pinned, tuple.conversationId)
        emitEvent(tuple.event)
        cache?.conversation?.pin(tuple.pinned, tuple.conversationId)
    }

    func mutual(_ request: MutualGroupsRequest) {
        requests[request.uniqueId] = request
        chat.prepareToSendAsync(req: request, type: .mutualGroups)
        let typeCode = request.toTypeCode(chat)
        cache?.mutualGroup?.mutualGroups(request.toBeUserVO.id ?? "") { [weak self] mutuals in
            self?.emitEvent(event: mutuals.toCachedMutualGroupEvent(request, typeCode))
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
        let tuple = asyncMessage.muteUnMuteTuple()
        chat.coordinator.conversation.onMuteOnMute(mute: tuple.mute, tuple.conversationId)
        emitEvent(tuple.event)
        cache?.conversation?.mute(tuple.mute, tuple.conversationId)
    }

    func leave(_ request: LeaveThreadRequest) {
        chat.prepareToSendAsync(req: request, type: .leaveThread)
    }

    func onLeaveThread(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<User> = asyncMessage.toChatResponse()
        emitEvent(.thread(.left(response)))
        cache?.participant?.delete([Participant(id: response.result?.id)], response.subjectId ?? -1)
        if response.result?.id == chat.userInfo?.id, let threadId = response.subjectId {
            chat.coordinator.conversation.onDeleteConversation(threadId)
            cache?.conversation?.delete(threadId)
        }
    }

    func onLastSeenUpdate(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<LastSeenMessageResponse> = asyncMessage.toChatResponse()
        emitEvent(.thread(.lastSeenMessageUpdated(response)))
        if let tuple = response.toCacheLastSeenTuple() {
            cache?.conversation?.seen(tuple.cacheLastSeenReponse)
            Task {
                await cache?.conversation?.updateThreadsUnreadCount(["\(tuple.threadId)": tuple.unreadCount])
            }
        }
    }

    func join(_ request: JoinPublicThreadRequest) {
        chat.prepareToSendAsync(req: request, type: .joinThread)
    }

    func onJoinThread(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Conversation> = asyncMessage.toChatResponse()
        chat.coordinator.conversation.onJoined(conversation: response.result)
        emitEvent(.thread(.joined(response)))
    }

    func delete(_ request: GeneralSubjectIdRequest) {
        chat.prepareToSendAsync(req: request, type: .deleteThread)
    }

    func onDeleteThread(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Participant> = asyncMessage.toChatResponse()
        chat.coordinator.conversation.onDeleteConversation(response.subjectId)
        emitEvent(.thread(.deleted(response)))
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
        emitEvent(.thread(.created(response)))
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
        chat.coordinator.conversation.onNewMessage(response.result)
        if let uniqueId = response.uniqueId, let request = requests[uniqueId] as? UploadFileRequest {
            chat.file.upload(request)
        }
    }

    func close(_ request: GeneralSubjectIdRequest) {
        chat.prepareToSendAsync(req: request, type: .closeThread)
    }

    func onCloseThread(_ asyncMessage: AsyncMessage) {
        var response: ChatResponse<Int> = asyncMessage.toChatResponse()
        response.result = response.subjectId
        chat.coordinator.conversation.onClosed(response.result)
        emitEvent(.thread(.closed(response)))
        cache?.conversation?.close(true, response.result ?? -1)
    }

    func changeType(_ request: ChangeThreadTypeRequest) {
        chat.prepareToSendAsync(req: request, type: .changeThreadType)
    }

    func onChangeThreadType(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Conversation> = asyncMessage.toChatResponse()
        cache?.conversation?.changeThreadType(response.result?.id ?? -1, response.result?.type ?? .unknown)
        chat.coordinator.conversation.onChangeConversationType(response.result)
        emitEvent(.thread(.changedType(response)))
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
        emitEvent(.thread(archived ? .archive(response) : .unArchive(response)))
    }

    func allUnreadCount(_ request: AllThreadsUnreadCountRequest) {
        chat.prepareToSendAsync(req: request, type: .allUnreadMessageCount)
        let typeCode = request.toTypeCode(chat)
        cache?.conversation?.allUnreadCount { [weak self] allUnreadCount in
            self?.emitEvent(event: allUnreadCount.toAllCachedUnreadCountEvent(request, typeCode))
        }
    }

    func onUnreadMessageCount(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Int> = asyncMessage.toChatResponse()
        emitEvent(.thread(.allUnreadCount(response)))
    }

    func lastAction(_ request: LastActionInConversationRequest) {
        chat.prepareToSendAsync(req: request, type: .lastActionInThread)
    }

    func onLastActionInThread(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[LastActionInConversation]> = asyncMessage.toChatResponse()
        emitEvent(.thread(.lastActions(response)))
    }
    
    private nonisolated func emitEvent(event: ChatEventType) {
        Task { @ChatGlobalActor [weak self] in
            self?.emitEvent(event)
        }
    }
    
    private func emitEvent(_ event: ChatEventType) {
        chat.delegate?.chatEvent(event: event)
    }
}
