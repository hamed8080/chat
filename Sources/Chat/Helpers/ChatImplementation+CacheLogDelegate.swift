//
// ChatImplementation+CacheLogDelegate.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/16/22

import ChatCache
import Foundation

extension ChatImplementation: CacheLogDelegate {}

public extension ChatImplementation {
    nonisolated func log(message: String, persist: Bool, error _: Error?) {
        Task { @ChatGlobalActor [weak self] in
            self?.logger.log(message: message, persist: persist, type: .internalLog)
        }
    }
}
