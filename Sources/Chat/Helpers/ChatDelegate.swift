//
// ChatDelegate.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/16/22

import Async
import Foundation
import Logger

public protocol ChatDelegate: AnyObject, LogDelegate {
    func chatState(state: ChatState, currentUser: User?, error: ChatError?)
    func chatError(error: ChatError)
    func chatEvent(event: ChatEventType)
}

public enum ChatEventType {
    case bot(BotEventTypes)
    case contact(ContactEventTypes)
    case file(FileEventType)
    case system(SystemEventTypes)
    case message(MessageEventTypes)
    case thread(ThreadEventTypes)
    case user(UserEventTypes)
    case assistant(AssistantEventTypes)
    case tag(TagEventTypes)
}
