//
// ChatDelegate.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

public protocol ChatDelegate: AnyObject {
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
    case call(CallEventTypes)
    case assistant(AssistantEventTypes)
    case tag(TagEventTypes)
}
