//
// ChatCoordinator.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/16/22

import Foundation

@ChatGlobalActor
protocol StoreTypes {
    var conversation: ThreadsStore { get }
    var history: HistoryStore { get }
    var reaction: ReactionsStore { get }
}

protocol ChatStoreProtocol: StoreTypes {
    var chat: ChatInternalProtocol { get }
    init(chat: ChatInternalProtocol)
    func invalidate()
}

public class ChatCoordinator: ChatStoreProtocol {
    let chat: ChatInternalProtocol
    let reaction: ReactionsStore
    let conversation: ThreadsStore
    let history: HistoryStore

    required init(chat: ChatInternalProtocol) {
        self.chat = chat
        reaction = .init(chat: chat)
        conversation = .init(chat: chat)
        history = .init(chat: chat)
    }

    func invalidate() {
        reaction.invalidate()
        conversation.invalidate()
        history.invalidate()
    }
}
