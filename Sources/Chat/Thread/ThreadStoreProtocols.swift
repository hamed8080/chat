//
// ThreadStoreProtocols.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatDTO
import ChatModels
import ChatCore

protocol InMemoryConversationOperations {
    associatedtype T: InMemoryConversation

    // In Memory operations
    func get(_ request: ThreadsRequest)
    func hasSomeSlots(_ request: ThreadsRequest) -> Bool
    func hasRange(offset: Int, count: Int) -> Bool
    func store(_ conversations: [Conversation], request: ThreadsRequest)
    func append(_ conversation: T)
    func appendAndSortIntoInMemory(conversations: [Conversation])
    func remove(_ convesation: T)
    func remove(_ convesationId: T.ID)
    func update(_ conversation: T)
    func indexOf(_ conversationId: T.ID) -> Array<T>.Index?
    func contains(_ conversationId: T.ID) -> Bool
    func emit(_ conversations: [T], _ uniqueId: String, _ hasNext: Bool)
    func makeEmptySlots(_ request: ThreadsRequest)
    func makeEmptySlot(for: Conversation.ID, at: Array<T>.Index)
    func emptySlot(id: Conversation.ID)
    func numberOfUnavailableSlots(_ request: ThreadsRequest) -> Int?
    func fetchUnavailableSlots(request: ThreadsRequest)
}

protocol ServerConversationOperations {
    // Server operations
    func fetch(request: ThreadsRequest)
    func respondByInMemory(_ request: ThreadsRequest)
    func getCompleteOffset(request: ThreadsRequest)
    func fetchUnavailableSlots(request: ThreadsRequest)
    func onFetchedThreads(_ response: ChatResponse<[Conversation]>)
    func request(for uniqueId: String, key: String) -> ThreadsRequestWrapper?
    func requestsContains(uniqueId: String) -> Bool
    func storePinThreads(_ conversations: [Conversation])
    func onPinUnPin(pin: Bool, _ conversationId: Conversation.ID)
    func onJoined(conversation: Conversation?)
    func onMuteOnMute(mute: Bool, _ conversationId: Conversation.ID)
    func onDeleteConversation(_ id: Conversation.ID)
    func onCreateConversation(_ conversation: Conversation?)
    func onNewMessage(_ message: Message?)
    func onClosed(_ id: Conversation.ID)
    func onArchiveUnArchive(archive: Bool, id: Conversation.ID)
    func onAddParticipant(_ id: Conversation.ID, count: Int)
    func onRemovedParticipants(_ id: Conversation.ID, count: Int)
}

protocol DBConversationOPerations {
    // Core Data operations
    func storeInDB(_ conversations: [Conversation])
}

protocol ThreadStoreProtocol: InMemoryConversationOperations, ServerConversationOperations, DBConversationOPerations {
    var conversations: ContiguousArray<T> { get set }
    var serverSortedPins: [Int] { get }
    var offset: Int { get set }
    var requests: [ThreadsRequestWrapper] { get set }
    var chat: ChatInternalProtocol { get }
    init(chat: ChatInternalProtocol)
    func invalidate()
}
