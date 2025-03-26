//
// ChatState.swift
// Copyright (c) 2022 ChatCore
//
// Created by Hamed Hosseini on 12/16/22

import Async
import Foundation

public enum ChatState: String, Identifiable, CaseIterable, Sendable {
    public var id: Self { self }
    case connecting
    case connected
    case closed
    case asyncReady
    case chatReady
    case uninitialized
}

public extension AsyncSocketState {
    var chatState: ChatState {
        ChatState(rawValue: rawValue) ?? .uninitialized
    }
}
