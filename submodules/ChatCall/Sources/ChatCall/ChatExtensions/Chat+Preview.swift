//
// Chat+Preview.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

import Foundation
import Chat
import ChatDTO

// Request
public extension ChatImplementation {
    func preview(startCall: StartCall) {
        initWebRTC(startCall)
    }
}
