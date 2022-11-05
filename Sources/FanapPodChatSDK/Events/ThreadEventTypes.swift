//
// ThreadEventTypes.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

public enum ThreadEventTypes {
    case threadClosed(threadId: Int)
    case threadUnreadCountUpdated(threadId: Int, count: Int)
    case threadLastActivityTime(time: Int, threadId: Int?)
    case threadPin(threadId: Int)
    case threadUnpin(threadId: Int)
    case threadInfoUpdated(Conversation)
    case threadUserRole(threadId: Int, roles: [UserRole])
    case threadAddParticipants(thread: Conversation, [Participant]?)
    case threadLeaveSaftlyFailed(threadId: Int)
    case threadLeaveParticipant(User)
    case threadRemovedFrom(threadId: Int)
    case threadMute(threadId: Int)
    case threadUnmute(threadId: Int)
    case threadsListChange([Conversation])
    case threadParticipantsListChange(threadId: Int?, [Participant])
    case threadNew(Conversation)
    case threadRemoveParticipants([Participant])
    case messagePin(threadId: Int?, PinUnpinMessage)
    case messageUnpin(threadId: Int?, PinUnpinMessage)
    case threadDeleted(threadId: Int, participant: Participant?)
}
