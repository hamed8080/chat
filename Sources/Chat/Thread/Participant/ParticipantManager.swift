//
// ParticipantManager.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Async
import ChatCache
import ChatCore
import ChatDTO
import ChatModels
import Foundation

final class ParticipantManager: ParticipantProtocol {
    let chat: ChatInternalProtocol

    init(chat: ChatInternalProtocol) {
        self.chat = chat
    }

    func get(_ request: ThreadParticipantRequest) {
        chat.prepareToSendAsync(req: request, type: .threadParticipants)
        let typeCode = request.toTypeCode(chat)
        let participantsCache = chat.cache?.participant
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            if let (participants, totalCount) = participantsCache?.getThreadParticipants(request.threadId, request.count, request.offset) {
            let participants = participants?.map(\.codable)
            let response = ChatResponse(uniqueId: request.uniqueId, result: participants, hasNext: totalCount >= request.count, cache: true, typeCode: typeCode)
                Task { @ChatGlobalActor [weak self] in
                    guard let self = self else { return }
                    chat.delegate?.chatEvent(event: .participant(.participants(response)))
                }
            }
        }
    }

    func onThreadParticipants(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[Participant]> = asyncMessage.toChatResponse(asyncManager: chat.asyncManager)
        var conversation = Conversation(id: response.subjectId)
        conversation.participants = response.result
        chat.delegate?.chatEvent(event: .participant(.participants(response)))
        chat.cache?.participant?.insert(model: conversation)
    }

    func remove(_ request: RemoveParticipantRequest) {
        chat.prepareToSendAsync(req: request, type: .removeParticipant)
    }

    func onRemoveParticipants(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[Participant]> = asyncMessage.toChatResponse()
        chat.cache?.participant?.delete(response.result ?? [], response.subjectId ?? -1)
        chat.coordinator.conversation.onRemovedParticipants(response.subjectId, count: response.result?.count ?? 0)
        chat.delegate?.chatEvent(event: .participant(.deleted(response)))
    }

    func add(_ request: AddParticipantRequest) {
        chat.prepareToSendAsync(req: request, type: .addParticipant)
    }

    func onAddParticipant(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Conversation> = asyncMessage.toChatResponse()
        guard let thread = response.result else { return }
        chat.coordinator.conversation.onAddParticipant(response.subjectId, count: response.result?.participantCount ?? 0)
        chat.cache?.participant?.insert(model: thread)
        chat.delegate?.chatEvent(event: .thread(.threads(.init(result: [thread], typeCode: response.typeCode))))
        chat.delegate?.chatEvent(event: .participant(.add(response)))
    }

    func addAdminRole(_ request: AdminRoleRequest) {
        chat.prepareToSendAsync(req: request, type: .setAdminRoleToUser)
    }

    func onSetAdminRoleToUser(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[AdminRoleResponse]> = asyncMessage.toChatResponse()
        chat.delegate?.chatEvent(event: .participant(.setAdminRoleToUser(response)))
        chat.cache?.participant?.addAdminRole(participantIds: response.result?.compactMap({$0.participant?.id}) ?? [])
    }

    func removeAdminRole(_ request: AdminRoleRequest) {
        chat.prepareToSendAsync(req: request, type: .removeAdminRoleFromUser)
    }

    func onRemoveAdminRoleFromUser(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[AdminRoleResponse]> = asyncMessage.toChatResponse()
        chat.delegate?.chatEvent(event: .participant(.removeAdminRoleFromUser(response)))
        chat.cache?.participant?.removeAdminRole(participantIds: response.result?.compactMap({$0.participant?.id}) ?? [])
    }
}
