//
// ParticipantEventTypes.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/2/22

import ChatCore
import ChatDTO
import ChatModels
import Foundation

public enum ParticipantEventTypes {
    case participants(ChatResponse<[Participant]>)
    case add(ChatResponse<Conversation>)
    case added(ChatResponse<[Participant]>)
    case deleted(ChatResponse<[Participant]>)
}
