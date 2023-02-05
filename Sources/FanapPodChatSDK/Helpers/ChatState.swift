//
// ChatState.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/2/22

import FanapPodAsyncSDK
import Foundation
public enum ChatState: String, Identifiable, CaseIterable {
    public var id: Self { self }
    case connecting
    case connected
    case closed
    case asyncReady
    case chatReady
    case uninitialized
}

extension AsyncSocketState {
    var chatState: ChatState {
        ChatState(rawValue: rawValue) ?? .uninitialized
    }
}
