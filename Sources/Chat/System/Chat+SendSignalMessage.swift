//
// Chat+SendSignalMessage.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/16/22

import ChatDTO
import Foundation

public extension Chat {
    /// Notify some system actions such as upload a file, record a voice and e.g.
    /// - Parameter req: A request that contains the type of request and a threadId.
    func sendSignalMessage(req: SendSignalMessageRequest) {
        prepareToSendAsync(req: req, type: .systemMessage)
    }
}
