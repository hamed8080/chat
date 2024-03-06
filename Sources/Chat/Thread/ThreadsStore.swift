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


protocol InMemoryConversationOperations {
    associatedtype T: InMemoryConversation

    // In Memory operations
    func get(_ request: ThreadsRequest)
    func hasRange(offset: Int, count: Int) -> Bool
    func store(_ conversations: [Conversation], request: ThreadsRequest)
    func append(_ conversation: T)
    func remove(_ convesation: T)
    func remove(_ convesationId: T.ID)
    func update(_ conversation: T)
    func indexOf(_ conversationId: T.ID) -> Array<T>.Index?
    func contains(_ conversationId: T.ID) -> Bool
    func emit(_ conversations: [T], _ uniqueId: String, _ hasNext: Bool)
    func makeEmptySlots(_ request: ThreadsRequest)
    func makeEmptySlot(for: Conversation.ID, at: Array<T>.Index)
    func emptySlot(id: Conversation.ID)
}

protocol ServerConversationOperations {
    // Server operations
    func fetch(request: ThreadsRequest)
    func onFetchedThreads(_ response: ChatResponse<[Conversation]>)
    func request(for uniqueId: String) -> ChatDTO.UniqueIdProtocol?
    func requestsContains(uniqueId: String) -> Bool
    func storePinThreads(_ conversations: [Conversation])
    func onPinUnPin(pin: Bool, _ conversationId: Conversation.ID)
}

protocol DBConversationOPerations {
    // Core Data operations
    func storeInDB(_ conversations: [Conversation])
}

protocol ThreadStoreProtocol: InMemoryConversationOperations, ServerConversationOperations, DBConversationOPerations {
    var conversations: ContiguousArray<T> { get set }
    var serverSortedPins: [Int] { get }
    var offset: Int { get set }
    var requests: [ChatDTO.UniqueIdProtocol] { get set }
    var chat: ChatInternalProtocol { get }
    init(chat: ChatInternalProtocol)
    func invalidate()
}

class InMemoryConversation: Identifiable {
    var id: Conversation.ID?
    var conversation: Conversation?
    var isEmptySlot: Bool { conversation == nil }
}

internal final class ThreadsStore: ThreadStoreProtocol {
    var conversations = ContiguousArray<InMemoryConversation>()
    var serverSortedPins: [Int] = []
    var offset: Int = 0
    var requests: [ChatDTO.UniqueIdProtocol] = []
    var chat: ChatInternalProtocol

    init(chat: ChatInternalProtocol) {
        self.chat = chat
    }

    // Input(offset: 0, count: 20) -> false
    func get(_ request: ThreadsRequest) {
        if request.threadIds?.isEmpty == false {
            fetch(request: request)
            return
        }
        if hasRange(offset: request.offset, count: request.count) {
            let nsrange = NSRange(location: request.offset, length: request.count)
            let range = Range(nsrange)!
            let conversations = conversations[range]
            emit(Array(conversations), request.uniqueId, true)
        } else {
            makeEmptySlots(request)
            fetch(request: request)
        }
    }

    // Input(offset: 0, count: 20) -> false
    // Input(offset: 20, count: 25) -> false
    // Input(offset: 0, count: 10) -> true
    // Input(offset: 0, count: 24) -> true
    func hasRange(offset: Int, count: Int) -> Bool {
        conversations.count > offset && conversations.count > offset + count
    }

    /// Make 0...24 slot = offset = 0 count = 25
    /// Make 25...49 slot = offset = 25 count = 25
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
            self.conversations[index] = inMemory
        }
    }

    func append(_ conversation: InMemoryConversation) {
        conversations.append(conversation)
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

    func fetch(request: ThreadsRequest) {
        chat.cache?.conversation?.fetch(request.fetchRequest) { [weak self] threads, totalCount in
            let threads = threads.map { $0.codable() }
            let hasNext = totalCount >= request.count
            let response = ChatResponse(uniqueId: request.uniqueId, result: threads, hasNext: hasNext, cache: true)
            self?.chat.delegate?.chatEvent(event: .thread(.threads(response)))
        }
        requests.append(request)
        chat.prepareToSendAsync(req: request, type: .getThreads)
    }

    func requestsContains(uniqueId: String) -> Bool {
        requests.contains(where: {$0.uniqueId == uniqueId})
    }

    func request(for uniqueId: String) -> ChatDTO.UniqueIdProtocol? {
        requests.first(where: {$0.uniqueId == uniqueId})
    }

    func onFetchedTop(_ response: ChatResponse<[Conversation]>) {
        response.result?.forEach{ conversation in
            if let index = indexOf(conversation.id) {
                conversations[index].conversation = conversation
            }
        }
    }

    func onFetchedThreads(_ response: ChatResponse<[Conversation]>) {
        guard let uniqueId = response.uniqueId else { return }
        let request = request(for: uniqueId)
        guard let request = request else {
            onFetchedTop(response)
            return
        }
        if let conversations = response.result, request != nil {
            store(conversations, request: request as! ThreadsRequest)
            storePinThreads(conversations)
            requests.removeAll(where: {$0.uniqueId == uniqueId})
            storeInDB(conversations)
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
        } else {
            serverSortedPins.removeAll(where: {$0 == conversationId})
            moveToProperPositionAfterUnPin(conversationId)
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

    func emit(_ conversations: [InMemoryConversation], _ uniqueId: String, _ hasNext: Bool) {
        let map = conversations.compactMap{$0.conversation}
        let res = ChatResponse<[Conversation]>(uniqueId: uniqueId,
                                               result: map,
                                               hasNext: hasNext,
                                               cache: false,
                                               time: Int(Date().millisecondsSince1970))
        chat.delegate?.chatEvent(event: .thread(.threads(res)))
    }
}
