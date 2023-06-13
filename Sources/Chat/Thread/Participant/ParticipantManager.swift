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

    func get(_ request: ThreadParticipantsRequest) {
        chat.prepareToSendAsync(req: request, type: .threadParticipants)
        chat.cache?.participant?.getParticipantsForThread(request.threadId, request.count, request.offset) { [weak self] participants, totalCount in
            let participants = participants.map(\.codable)
            self?.chat.responseQueue.async {
                let response = ChatResponse(uniqueId: request.uniqueId, result: participants, hasNext: totalCount >= request.count, cache: true)
                self?.chat.delegate?.chatEvent(event: .participant(.participants(response)))
            }
        }
    }

    func admins(_ request: ThreadParticipantsRequest) {
        get(.init(request: request, admin: true))
    }

    func onThreadParticipants(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[Participant]> = asyncMessage.toChatResponse(asyncManager: chat.asyncManager)
        let conversation = Conversation(id: response.subjectId)
        conversation.participants = response.result
        chat.delegate?.chatEvent(event: .participant(.participants(response)))
        chat.cache?.participant?.insert(model: conversation)
    }

    func remove(_ request: RemoveParticipantsRequest) {
        chat.prepareToSendAsync(req: request, type: .removeParticipant)
    }

    func onRemoveParticipants(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[Participant]> = asyncMessage.toChatResponse()
        chat.cache?.participant?.delete(response.result ?? [])
        chat.delegate?.chatEvent(event: .participant(.deleted(response)))
        chat.delegate?.chatEvent(event: .thread(.activity(.init(result: .init(time: response.time, threadId: response.subjectId)))))
    }

    func add(_ request: AddParticipantRequest) {
        chat.prepareToSendAsync(req: request, type: .addParticipant)
    }

    func onAddParticipant(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Conversation> = asyncMessage.toChatResponse()
        chat.cache?.participant?.insert(model: response.result)
        chat.delegate?.chatEvent(event: .thread(.activity(.init(result: .init(time: response.time, threadId: response.subjectId)))))
        chat.delegate?.chatEvent(event: .participant(.add(response)))
    }
}
