//
// ContactEventTypes.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

public enum ContactEventTypes {
    case blocked(BlockedContact, id: Int?)
    case contactsLastSeen([UserLastSeenDuration])
}
