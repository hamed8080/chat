//
// TagManager.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Async
import ChatCore
import ChatDTO
import ChatModels
import Foundation

final class TagManager: TagProtocol {
    let chat: ChatInternalProtocol

    init(chat: ChatInternalProtocol) {
        self.chat = chat
    }

    func participants(_ request: GetTagParticipantsRequest) {
        chat.prepareToSendAsync(req: request, type: .getTagParticipants)
    }

    func onTagParticipants(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[TagParticipant]> = asyncMessage.toChatResponse()
        chat.cache?.tagParticipant?.insert(models: response.result?.compactMap { $0 } ?? [])
        chat.delegate?.chatEvent(event: .tag(.participants(response)))
    }

    func all() {
        let req = BareChatSendableRequest()
        chat.prepareToSendAsync(req: req, type: .tagList)
        let typeCode = chat.config.typeCodes[req.chatTypeCodeIndex].typeCode
        let tagCache = chat.cache?.tag
        Task { @MainActor in
            let tagModels = tagCache?.getTags().map(\.codable)
            let response = ChatResponse(uniqueId: req.uniqueId, result: tagModels, cache: true, typeCode: typeCode)
            Task { @ChatGlobalActor [weak self] in
                self?.chat.delegate?.chatEvent(event: .tag(.tags(response)))
            }
        }
    }

    func onTags(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[Tag]> = asyncMessage.toChatResponse()
        chat.cache?.tag?.insert(models: response.result ?? [])
        chat.delegate?.chatEvent(event: .tag(.tags(response)))
    }

    func remove(_ request: RemoveTagParticipantsRequest) {
        chat.prepareToSendAsync(req: request, type: .removeTagParticipants)
    }

    func onRemoveTagParticipants(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[TagParticipant]> = asyncMessage.toChatResponse()
        chat.delegate?.chatEvent(event: .tag(.removed(response)))
        chat.cache?.tagParticipant?.delete(response.result ?? [], tagId: response.subjectId ?? -1)
    }

    func edit(_ request: EditTagRequest) {
        chat.prepareToSendAsync(req: request, type: .editTag)
    }

    func onEditTag(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Tag> = asyncMessage.toChatResponse()
        chat.delegate?.chatEvent(event: .tag(.edited(response)))
        chat.cache?.tag?.insert(models: [response.result].compactMap { $0 })
    }

    func delete(_ request: DeleteTagRequest) {
        chat.prepareToSendAsync(req: request, type: .deleteTag)
    }

    func onDeleteTag(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Tag> = asyncMessage.toChatResponse()
        chat.delegate?.chatEvent(event: .tag(.deleted(response)))
        chat.cache?.tag?.delete(response.result?.id ?? -1)
    }

    func create(_ request: CreateTagRequest) {
        chat.prepareToSendAsync(req: request, type: .createTag)
    }

    func onCreateTag(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Tag> = asyncMessage.toChatResponse()
        chat.delegate?.chatEvent(event: .tag(.created(response)))
        chat.cache?.tag?.insert(models: [response.result].compactMap { $0 })
    }

    func add(_ request: AddTagParticipantsRequest) {
        chat.prepareToSendAsync(req: request, type: .addTagParticipants)
    }

    func onAddTagParticipant(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[TagParticipant]> = asyncMessage.toChatResponse()
        chat.delegate?.chatEvent(event: .tag(.added(response)))
        chat.cache?.tagParticipant?.insert(models: response.result?.compactMap { $0 } ?? [])
    }
}
