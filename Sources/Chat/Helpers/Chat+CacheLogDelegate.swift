//
// Chat+CacheLogDelegate.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/16/22

import ChatCache
import Foundation

extension Chat: CacheLogDelegate {}

public extension Chat {
    func log(message: String, persist: Bool, error _: Error?) {
        logger.log(message: message, persist: persist, type: .internalLog)
    }
}
