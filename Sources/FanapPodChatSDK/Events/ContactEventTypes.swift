//
// ContactEventTypes.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/2/22

import Foundation

public enum ContactEventTypes {
    case blocked(ChatResponse<BlockedContact>)
    case contactsLastSeen(ChatResponse<[UserLastSeenDuration]>)
}
