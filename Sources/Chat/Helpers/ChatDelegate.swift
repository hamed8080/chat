//
// ChatDelegate.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/16/22

import Async
import ChatCore
import ChatModels
import Foundation
import Logger

public protocol ChatDelegate: AnyObject, LogDelegate, Sendable {
    func chatState(state: ChatState, currentUser: User?, error: ChatError?)
    func chatEvent(event: ChatEventType)
}
