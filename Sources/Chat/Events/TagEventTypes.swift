//
// TagEventTypes.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/3/22

import ChatCore
import ChatModels
import Foundation

public enum TagEventTypes {
    case created(ChatResponse<Tag>)
    case deleted(ChatResponse<Tag>)
    case edited(ChatResponse<Tag>)
    case added(ChatResponse<[TagParticipant]>)
    case removed(ChatResponse<[TagParticipant]>)
    case tags(ChatResponse<[Tag]>)
    case participants(ChatResponse<[TagParticipant]>)
}
