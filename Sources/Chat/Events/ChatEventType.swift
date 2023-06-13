//
// ChatDelegate.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/16/22
import Foundation

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
    case call(CallEventTypes)
    case participant(ParticipantEventTypes)
    case map(MapEventTypes)
}
