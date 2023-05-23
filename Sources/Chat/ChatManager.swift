//
// ChatManager.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/16/22

import ChatCache
import ChatCore
import ChatDTO
import ChatModels
import Foundation

public final class ChatManager {
    private init() {}
    public static var instance: ChatManager = .init()
    public static var activeInstance: Chat?
    private var instances: [UUID: Chat] = [:]

    private func createInstance(config: ChatConfig) {
        let chat = ChatImplementation(config: config)
        instances[chat.id] = chat
        ChatManager.activeInstance = chat
    }

    public func switchInstance(chatId: UUID) {
        ChatManager.activeInstance = instances[chatId]
    }

    public func removeInstance(chatId: UUID) {
        instances.removeValue(forKey: chatId)
    }

    public func createOrReplaceUserInstance(userId: Int? = nil, config: ChatConfig) {
        if let userId = userId, let key = instances.first(where: { ($0.value as? ChatInternalProtocol)?.userInfo?.id == userId })?.key {
            ChatManager.activeInstance = instances[key]
        } else {
            createInstance(config: config)
        }

        if let userId = userId {
            ChatManager.switchToUser(userId: userId)
        }
    }

    public final class func switchToUser(userId: Int) {
        guard let activeInstance = activeInstance as? ChatInternalProtocol else { return }
        activeInstance.cache?.switchToContainer(userId: userId)
    }
}
