//
// TagEventTypes.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

public enum TagEventTypes {
    case createTag(_ tag: Tag)
    case deleteTag(_ tag: Tag)
    case editTag(_ tag: Tag)
    case addTagParticipant(_ participants: [TagParticipant])
    case removeTagParticipant(_ participants: [TagParticipant])
}
