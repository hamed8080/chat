//
// ChatState.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/2/22

import FanapPodAsyncSDK
import Foundation
public enum ChatState: String {
    case connecting
    case connected
    case closed
    case asyncReady
    case chatReady
}

extension AsyncSocketState {
    var chatState: ChatState {
        ChatState(rawValue: rawValue) ?? ChatState.closed
    }
}
