//
// ContactEventTypes.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/2/22

import Foundation

public enum ContactEventTypes {
    case blocked(ChatResponse<Contact>)
    case contactsLastSeen(ChatResponse<[UserLastSeenDuration]>)
}
