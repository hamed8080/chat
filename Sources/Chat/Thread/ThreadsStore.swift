//
// ThreadsStore.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import ChatModels
import ChatDTO
import Foundation
import ChatCore
import Additive
import ChatExtensions

internal final class InMemoryConversation: Identifiable {
    var id: Conversation.ID?
    var conversation: Conversation?
    var isEmptySlot: Bool { conversation == nil }
}

internal struct ThreadsRequestWrapper {
    let key: String
    let request: ThreadsRequest
    let originalRequest: ThreadsRequest
}

internal final class ThreadsStore: ThreadStoreProtocol {
    var conversations = ContiguousArray<InMemoryConversation>()
    var serverSortedPins: [Int] = []
    var offset: Int = 0
    var requests: [ThreadsRequestWrapper] = []
    var chat: ChatInternalProtocol

    init(chat: ChatInternalProtocol) {
        self.chat = chat
    }

    func get(_ request: ThreadsRequest) {
        // Direct request to the server and the SQLITE Store to fetch data.
        if !request.isCacheableInMemoryRequest {
            fetch(request: request)
            return
        }

        if request.cache == false {
            invalidate()
        }

        if hasRange(offset: request.offset, count: request.count) {
            respondByInMemory(request)
        } else if hasSomeSlots(request) {
            fetchUnavailableSlots(request: request)
        } else {
            makeEmptySlots(request)
            getCompleteOffset(request: request)
        }
    }

    func respondByInMemory(_ request: ThreadsRequest) {
        let nsrange = NSRange(location: request.offset, length: request.count)
        let range = Range(nsrange)!
        let conversations = conversations[range]
        emit(Array(conversations), request.uniqueId, true)
    }

    func hasRange(offset: Int, count: Int) -> Bool {
        conversations.count >= offset && conversations.count >= offset + count
    }

    func hasSomeSlots(_ request: ThreadsRequest) -> Bool {
        return conversations.count > request.offset
    }

    func numberOfUnavailableSlots(_ request: ThreadsRequest) -> Int? {
        return request.count - conversations.count
    }

    func makeEmptySlots(_ request: ThreadsRequest) {
        let lastIndex = max(0, conversations.count - 1)
        let range = lastIndex..<(lastIndex + request.count)
        range.forEach { index in
            conversations.append(InMemoryConversation())
        }
    }

    func makeEmptySlot(for id: Conversation.ID, at index: Array<InMemoryConversation>.Index) {
        let inMemory = InMemoryConversation()
        inMemory.id = id
        conversations.insert(inMemory, at: index)
    }

    func emptySlot(id: Conversation.ID) {
        if let index = indexOf(id) {
            conversations[index].id = nil
            conversations[index].conversation = nil
        }
    }

    /// 0...24 offset = 0 count = 25
    /// 25...49 offset = 25 count = 25
    func store(_ conversations: [Conversation], request: ThreadsRequest) {
        let start = request.offset
        let end = start + (conversations.count - 1)
        let range = start...end
        range.forEach { index in
            let inMemory = InMemoryConversation()
            let indexInList = max(0, index - request.offset)
            let conversation = conversations[indexInList]
            inMemory.conversation = conversation
            inMemory.id = conversation.id
            if conversations.indices.contains(index) {
                self.conversations[index] = inMemory
            }
        }
    }

    func append(_ conversation: InMemoryConversation) {
        conversations.append(conversation)
    }

    func appendAndSortIntoInMemory(conversations: [Conversation]) {
        conversations.forEach { conversation in
            let inMemory = InMemoryConversation()
            inMemory.conversation = conversation.copy
            inMemory.id = conversation.id
            self.conversations.append(inMemory)
        }
        sort()
    }

    func remove(_ convesation: InMemoryConversation) {
        conversations.removeAll(where: {$0.id == convesation.id})
    }

    func remove(_ convesationId: InMemoryConversation.ID) {
        conversations.removeAll(where: {$0.id == convesationId})
    }

    func indexOf(_ conversationId: InMemoryConversation.ID) -> Array<InMemoryConversation>.Index? {
        conversations.firstIndex(where: {$0.id == conversationId})
    }

    func update(_ conversation: InMemoryConversation) {
        if let index = indexOf(conversation.id ?? 0) {
            conversations[index] = conversation
        }
    }

    func contains(_ conversationId: InMemoryConversation.ID) -> Bool {
        return conversations.contains(where: {$0.id == conversationId})
    }

    func storeInDB(_ conversations: [Conversation]) {
        chat.cache?.conversation?.insert(models: conversations)
    }

    func requestsContains(uniqueId: String) -> Bool {
        requests.contains(where: {$0.request.uniqueId == uniqueId})
    }

    func request(for uniqueId: String, key: String) -> ThreadsRequestWrapper? {
        requests.first(where: {$0.request.uniqueId == uniqueId && $0.key == key})
    }

    func onFetchedThreads(_ response: ChatResponse<[Conversation]>) {
        guard let uniqueId = response.uniqueId else { return }
        if let completeOffsetRequest = request(for: uniqueId, key: "GET-COMPLETE-OFFSET") {
            onGetCompleteOffset(response, completeOffsetRequest)
        } else if let unavilableRequest = request(for: uniqueId, key: "GET-UNAVAILABLE-OFFSETS") {
            onGetUnavailableOffsets(response, unavilableRequest)
        } else {
            // Search in threads or requsts with threadIds
            // It is need to update the conversation for example if a new message comes from the bottom parts
            // We should wait for the client to request for that thread
            // Once the result has arrived we can update our in memory and fill it.
            response.result?.forEach{ conversation in
                if let index = indexOf(conversation.id) {
                    conversations[index].conversation = conversation.copy
                }
            }
            chat.delegate?.chatEvent(event: .thread(.threads(response)))
        }
    }

    func getCompleteOffset(request: ThreadsRequest) {
        requests.append(.init(key: "GET-COMPLETE-OFFSET", request: request, originalRequest: request))
        fetch(request: request)
    }

    func fetch(request: ThreadsRequest) {
        chat.cache?.conversation?.fetch(request.fetchRequest) { [weak self] threads, totalCount in
            let threads = threads.map { $0.codable() }
            let hasNext = totalCount >= request.count
            let response = ChatResponse(uniqueId: request.uniqueId, result: threads, hasNext: hasNext, cache: true)
            self?.chat.delegate?.chatEvent(event: .thread(.threads(response)))
        }
        chat.prepareToSendAsync(req: request, type: .getThreads)
    }

    private func onGetCompleteOffset(_ response: ChatResponse<[Conversation]>,_ request: ThreadsRequestWrapper) {
        guard let uniqueId = response.uniqueId else { return }
        if let conversations = response.result?.compactMap({$0.copy}) {
            store(conversations, request: request.originalRequest)
            storePinThreads(conversations)
            requests.removeAll(where: {$0.request.uniqueId == uniqueId})
            storeInDB(conversations)
        }
        chat.delegate?.chatEvent(event: .thread(.threads(response)))
    }

    func fetchUnavailableSlots(request: ThreadsRequest) {
        guard let count = numberOfUnavailableSlots(request) else { return }
        let newReq = request.copyWith(count: abs(count), offset: conversations.count)
        requests.append(.init(key: "GET-UNAVAILABLE-OFFSETS", request: newReq, originalRequest: request))
        fetch(request: newReq)
    }

    private func onGetUnavailableOffsets(_ response: ChatResponse<[Conversation]>, _ request: ThreadsRequestWrapper) {
        guard let uniqueId = response.uniqueId else { return }
        let conversations = response.result?.compactMap{$0.copy} ?? []
        appendAndSortIntoInMemory(conversations: conversations)
        requests.removeAll(where: {$0.request.uniqueId == uniqueId})
        storeInDB(conversations)
        let hasNext = request.request.count == conversations.count
        let startIndex = request.originalRequest.offset
        let length = request.originalRequest.count
        let endIndex = startIndex + length
        let nsRange = NSRange(location: startIndex, length: length)
        if let range = Range(nsRange), startIndex < endIndex, self.conversations.count >= endIndex {
            let mergedConversations = self.conversations[range]
            emit(Array(mergedConversations), request.originalRequest.uniqueId, hasNext)
        } else {
            // There were no bottom part client requested we have to repond with available threads.
            let startIndex = request.originalRequest.offset
            let endIndex = self.conversations.count - 1
            let conversations = self.conversations[startIndex...endIndex]
            emit(Array(conversations), request.originalRequest.uniqueId, hasNext)
        }
    }

    func storePinThreads(_ conversations: [Conversation]) {
        let pinThreads = conversations.filter{$0.pin == true}
        if serverSortedPins.isEmpty, !pinThreads.isEmpty {
            serverSortedPins = pinThreads.compactMap{$0.id}
        }
    }

    func onPinUnPin(pin: Bool, _ conversationId: Conversation.ID) {
        guard let conversationId = conversationId else { return }
        if let index = indexOf(conversationId) {
            conversations[index].conversation?.pin = pin;
        }
        if pin {
            serverSortedPins.insert(conversationId, at: 0)
            fetchPinnedIfIsNotInList(conversationId)
            sort()
        } else {
            serverSortedPins.removeAll(where: {$0 == conversationId})
            moveToProperPositionAfterUnPin(conversationId)
        }
    }

    func onMuteOnMute(mute: Bool, _ conversationId: Conversation.ID) {
        guard let conversationId = conversationId else { return }
        if let index = indexOf(conversationId) {
            conversations[index].conversation?.mute = mute;
        }
    }

    func onJoined(conversation: Conversation?) {
        if let copy = conversation?.copy {
            appendAndSortIntoInMemory(conversations: [copy])
        }
    }

    func onDeleteConversation(_ id: Conversation.ID) {
        remove(id)
    }

    func onCreateConversation(_ conversation: Conversation?) {
        if let copy = conversation?.copy {
            appendAndSortIntoInMemory(conversations: [copy])
        }
    }

    func onNewMessage(_ message: Message?) {
        if let message = message?.copy, let conversationId = message.conversation?.id {
            if contains(conversationId), let index = indexOf(conversationId) {
                conversations[index].conversation?.lastMessageVO = message
                conversations[index].conversation?.lastMessage = message.message
            } else {
                // Insert empty slot at the top
                appendAndSortIntoInMemory(conversations: [.init(id: conversationId)])
            }
        }
    }

    func onClosed(_ id: Conversation.ID) {
        if let index = indexOf(id) {
            conversations[index].conversation?.closedThread = true;
        }
    }

    func onChangeConversationType(_ conversation: Conversation?) {
        if let copy = conversation?.copy, let index = indexOf(copy.id) {
            conversations[index].conversation?.type = copy.type
        }
    }

    func onArchiveUnArchive(archive: Bool, id: Conversation.ID) {
        guard let conversationId = id else { return }
        if let index = indexOf(conversationId) {
            conversations[index].conversation?.isArchive = archive;
        }
    }

    func onAddParticipant(_ id: Conversation.ID, count: Int) {
        guard let conversationId = id else { return }
        if let index = indexOf(conversationId) {
            conversations[index].conversation?.participantCount = count
        }
    }

    func onRemovedParticipants(_ id: Conversation.ID, count: Int) {
        if let index = indexOf(id) {
            let currentCount = conversations[index].conversation?.participantCount ?? 0
            conversations[index].conversation?.participantCount = max(0, currentCount - count)
        }
    }

    private func fetchPinnedIfIsNotInList(_ id: Conversation.ID) {
        if !conversations.contains(where: {$0.conversation?.id == id}) {
            // 1- Create an empty slot at the position of 0 and set the id to it
            makeEmptySlot(for: id, at: 0)
            // 2- Then the app tries to get this unavailable thread from a request.
            // 3- onFetchedTop method we will update the slot.
        }
    }

    private func moveToProperPositionAfterUnPin(_ id: Conversation.ID) {
        guard let lastItemTime = conversations.last?.conversation?.time else { return }
        let unpinedDate = conversations.first(where: {$0.conversation?.id == id})?.conversation?.time ?? 0
        if lastItemTime < unpinedDate {
            sort()
        } else {
            emptySlot(id: id)
        }
    }

    private func sort() {
        conversations.sort(by: { $0.conversation?.time ?? 0 > $1.conversation?.time ?? 0 })
        conversations.sort(by: {
            let pin = $1.conversation?.pin
            let isNotPin = pin == false || pin == nil
            return $0.conversation?.pin == true && isNotPin
        })
        conversations.sort(by: { (firstItem, secondItem) in
            guard let firstIndex = serverSortedPins.firstIndex(where: {$0 == firstItem.id}),
                  let secondIndex = serverSortedPins.firstIndex(where: {$0 == secondItem.id}) else {
                return false // Handle the case when an element is not found in the server-sorted array
            }
            return firstIndex < secondIndex
        })
    }

    func invalidate() {
        offset = 0
        serverSortedPins.removeAll()
        requests.removeAll()
        conversations.removeAll()
    }

    func onPinUnPin(_ isPin: Bool, _ threadId: Int?, _ message: PinMessage?) {
        if let index = indexOf(threadId) {
            conversations[index].conversation?.pinMessage = isPin ? message : nil
        }
    }

    /// Emit a copy version of the conversaiton object
    func emit(_ conversations: [InMemoryConversation], _ uniqueId: String, _ hasNext: Bool) {
        let map = conversations.compactMap{$0.conversation?.copy}
        let res = ChatResponse<[Conversation]>(uniqueId: uniqueId,
                                               result: map,
                                               hasNext: hasNext,
                                               cache: false,
                                               time: Int(Date().millisecondsSince1970))
        chat.delegate?.chatEvent(event: .thread(.threads(res)))
    }
}
