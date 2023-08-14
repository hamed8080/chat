//
// ReactionEventTypes.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/2/22

import ChatCore
import ChatDTO
import ChatModels
import Foundation

public enum ReactionEventTypes {
    case count(ChatResponse<[ReactionCountList]>)
    case list(ChatResponse<ReactionList>)
    case add(ChatResponse<ReactionMessageResponse>)
    case reaplce(ChatResponse<ReactionMessageResponse>)
    case delete(ChatResponse<ReactionMessageResponse>)
}
