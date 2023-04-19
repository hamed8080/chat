//
// TagEventTypes.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/3/22

import ChatCore
import ChatModels
import Foundation

public enum TagEventTypes {
    case createTag(ChatResponse<Tag>)
    case deleteTag(ChatResponse<Tag>)
    case editTag(ChatResponse<Tag>)
    case addTagParticipant(ChatResponse<[TagParticipant]>)
    case removeTagParticipant(ChatResponse<[TagParticipant]>)
}
