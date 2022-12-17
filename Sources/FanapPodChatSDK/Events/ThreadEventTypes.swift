//
// ThreadEventTypes.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/16/22

import Foundation

public enum ThreadEventTypes {
    case threadClosed(ChatResponse<Int>)
    case threadUnreadCountUpdated(ChatResponse<UnreadCount>)
    case threadLastActivityTime(ChatResponse<ThreadLastActivity>)
    case threadPin(ChatResponse<Int>)
    case threadUnpin(ChatResponse<Int>)
    case threadInfoUpdated(ChatResponse<Conversation>)
    case threadUserRole(ChatResponse<[UserRole]>)
    case threadAddParticipants(ChatResponse<[Participant]>)
    case threadLeaveSaftlyFailed(ChatResponse<Int>)
    case threadLeaveParticipant(ChatResponse<User>)
    case threadRemovedFrom(ChatResponse<Int>)
    case threadMute(ChatResponse<Int>)
    case threadUnmute(ChatResponse<Int>)
    case threadsListChange(ChatResponse<[Conversation]>)
    case threadParticipantsListChange(ChatResponse<[Participant]>)
    case threadNew(ChatResponse<Conversation>)
    case threadRemoveParticipants(ChatResponse<[Participant]>)
    case messagePin(ChatResponse<PinUnpinMessage>)
    case messageUnpin(ChatResponse<PinUnpinMessage>)
    case threadDeleted(ChatResponse<Participant>)
    case lastMessageDeleted(ChatResponse<Conversation>)
    case lastMessageEdited(ChatResponse<Conversation>)
}
