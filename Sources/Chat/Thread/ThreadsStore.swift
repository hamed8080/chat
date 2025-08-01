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

@ChatGlobalActor
internal final class ThreadsStore: ThreadStoreProtocol {
    var conversations = ContiguousArray<InMemoryConversation>()
    var serverSortedPins: [Int] = []
    var requests: [ThreadsRequestWrapper] = []
    var chat: ChatInternalProtocol
    private var debug = ProcessInfo().environment["ENABLE_THREAD_STORE_LOGGING"] == "1"

    init(chat: ChatInternalProtocol) {
        self.chat = chat
    }

    func get(_ request: ThreadsRequest) {
        // Direct request to the server and the SQLITE Store to fetch data.
        log("Start getting threads. The number of items in memory is:\(conversations.count) and number of requests currently is:\(requests.count)")
        if !request.isCacheableInMemoryRequest {
            fetch(request: request)
            log("Direct request to the server as a result of request type is not memory cacheable.")
            return
        }

        if request.cache == false {
            invalidate()
            log("Invalidating the cache due to cache was false")
        }

        if hasRange(offset: request.offset, count: request.count) {
            respondByInMemory(request)
            log("ThreadsStore has the range, offset: \(request.offset) count: \(request.count)")
        } else if hasSomeSlots(request) {
            fetchUnavailableSlots(request: request)
            log("ThreadsStore has some parts, offset: \(request.offset) count: \(request.count)")
        } else {
            makeEmptySlots(request)
            getCompleteOffset(request: request)
            log("ThreadsStore doesn't have any range, request to fetch from server offset: \(request.offset) count: \(request.count)")
        }
    }

    func respondByInMemory(_ request: ThreadsRequest) {
        let nsrange = NSRange(location: request.offset, length: request.count)
        let range = Range(nsrange)!
        if conversations.count > 0 {
            let conversations = conversations[range]
            emit(Array(conversations), request.uniqueId, request.toTypeCode(chat), true)
        }
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
        if conversations.count == 0 { return } // prevent crash at the last page
        let start = request.offset
        let end = start + (conversations.count - 1)
        let range = start...end
        range.forEach { index in
            let inMemory = InMemoryConversation()
            let indexInList = max(0, index - request.offset)
            let conversation = conversations[indexInList]
            inMemory.conversation = conversation
            inMemory.id = conversation.id
            if self.conversations.indices.contains(index) {
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
            inMemory.conversation = conversation
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
        let copies = response.result?.map{$0} ?? []
        if let completeOffsetRequest = request(for: uniqueId, key: "GET-COMPLETE-OFFSET") {
            onGetCompleteOffset(response, completeOffsetRequest)
        } else if let unavilableRequest = request(for: uniqueId, key: "GET-UNAVAILABLE-OFFSETS") {
            onGetUnavailableOffsets(response, unavilableRequest)
        } else {
            // Search in threads or requsts with threadIds
            // It is need to update the conversation for example if a new message comes from the bottom parts
            // We should wait for the client to request for that thread
            // Once the result has arrived we can update our in memory and fill it.
            copies.forEach{ conversation in
                if let index = indexOf(conversation.id) {
                    conversations[index].conversation = conversation
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
        let typeCode = request.toTypeCode(chat)
        let conversationCache = chat.cache?.conversation
        Task { @MainActor in
            if let (threads, totalCount) = conversationCache?.fetch(request.fetchRequest) {
                let threads = threads.map { $0.codable() }
                let hasNext = totalCount >= request.count
                let response = ChatResponse(uniqueId: request.uniqueId, result: threads, hasNext: hasNext, cache: true, typeCode: typeCode)
                Task { @ChatGlobalActor [weak self] in
                    self?.chat.delegate?.chatEvent(event: .thread(.threads(response)))
                }
            }
        }
        chat.prepareToSendAsync(req: request, type: .getThreads)
    }

    private func onGetCompleteOffset(_ response: ChatResponse<[Conversation]>,_ request: ThreadsRequestWrapper) {
        guard let uniqueId = response.uniqueId else { return }
        if let conversations = response.result?.compactMap({$0}) {
            store(conversations, request: request.originalRequest)
            storePinThreads(conversations)
            requests.removeAll(where: {$0.request.uniqueId == uniqueId})
            storeInDB(conversations)
        }
        chat.delegate?.chatEvent(event: .thread(.threads(response)))
    }

    func fetchUnavailableSlots(request: ThreadsRequest) {
        guard let count = numberOfUnavailableSlots(request) else { return }
        var newReq = request
        newReq.count = abs(count)
        newReq.offset = conversations.count
        requests.append(.init(key: "GET-UNAVAILABLE-OFFSETS", request: newReq, originalRequest: request))
        fetch(request: newReq)
    }

    private func onGetUnavailableOffsets(_ response: ChatResponse<[Conversation]>, _ request: ThreadsRequestWrapper) {
        guard let uniqueId = response.uniqueId else { return }
        let conversations = response.result?.compactMap{$0} ?? []
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
            emit(Array(mergedConversations), request.originalRequest.uniqueId, response.typeCode, hasNext)
        } else {
            // There were no bottom part client requested we have to repond with available threads.
            let startIndex = request.originalRequest.offset
            let endIndex = self.conversations.count - 1
            let conversations = self.conversations[startIndex...endIndex]
            emit(Array(conversations), request.originalRequest.uniqueId, response.typeCode, hasNext)
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
        if let copy = conversation {
            appendAndSortIntoInMemory(conversations: [copy])
        }
    }

    func onDeleteConversation(_ id: Conversation.ID) {
        remove(id)
    }

    func onCreateConversation(_ conversation: Conversation?) {
        // We have to check the array for duplicate insertion.
        if let copy = conversation, !conversations.contains(where: { $0.id == conversation?.id}) {
            appendAndSortIntoInMemory(conversations: [copy])
        }
    }

    func onNewMessage(_ message: Message?) {
        if let message = message, let conversationId = message.conversation?.id {
            if contains(conversationId), let index = indexOf(conversationId) {
                conversations[index].conversation?.lastMessageVO = message.toLastMessageVO
                conversations[index].conversation?.lastMessage = message.message
            } else {
                // Insert empty slot at the top
                appendAndSortIntoInMemory(conversations: [.init(id: conversationId)])
            }
        }
    }

    func onClosed(_ id: Conversation.ID) {
        if let index = indexOf(id) {
            conversations[index].conversation?.closed = true;
        }
    }

    func onChangeConversationType(_ conversation: Conversation?) {
        if let copy = conversation, let index = indexOf(copy.id) {
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
        log("Invalidating the cache")
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
    func emit(_ conversations: [InMemoryConversation], _ uniqueId: String, _ typeCode: String?, _ hasNext: Bool) {
        let map = conversations.compactMap{$0.conversation}
        let res = ChatResponse<[Conversation]>(uniqueId: uniqueId,
                                               result: map,
                                               hasNext: hasNext,
                                               cache: false,
                                               time: Int(Date().millisecondsSince1970),
                                               typeCode: typeCode)
        chat.delegate?.chatEvent(event: .thread(.threads(res)))
    }

    private func log(_ message: String) {
#if DEBUG
        if debug {
            chat.logger.log(title: "ThreadsStore", message: message, persist: false, type: .internalLog, userInfo: [:])
        }
#endif
    }
}
