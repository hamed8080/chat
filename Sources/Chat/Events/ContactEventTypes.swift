//
// ContactEventTypes.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/2/22

import ChatCore
import ChatDTO
import ChatModels
import Foundation

public enum ContactEventTypes {
    case blocked(ChatResponse<Contact>)
    case contactsLastSeen(ChatResponse<[UserLastSeenDuration]>)
}
