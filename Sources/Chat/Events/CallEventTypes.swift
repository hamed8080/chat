//
// CallEventTypes.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/2/22

import ChatCore
import ChatDTO
import ChatModels
import Foundation

public enum CallEventTypes: Sendable {
    case callCreate(ChatResponse<CreateCall>)
    case callStarted(ChatResponse<StartCall>)
    case callReceived(ChatResponse<CreateCall>)
    case callDelivered(ChatResponse<Call>)
    case callEnded(ChatResponse<Int>?)
    case callCanceled(ChatResponse<Call>)
    case groupCallCanceled(ChatResponse<CancelGroupCall>)
    case callRejected(ChatResponse<CreateCall>)
    case startCallRecording(ChatResponse<Participant>)
    case stopCallRecording(ChatResponse<Participant>)
    case callParticipantJoined(ChatResponse<[CallParticipant]>)
    case callParticipantLeft(ChatResponse<[CallParticipant]>)
    case callParticipantMute(ChatResponse<[CallParticipant]>)
    case callParticipantUnmute(ChatResponse<[CallParticipant]>)
    case callParticipantsRemoved(ChatResponse<[CallParticipant]>)
    case turnVideoOn(ChatResponse<[CallParticipant]>)
    case turnVideoOff(ChatResponse<[CallParticipant]>)
    case callError(ChatResponse<CallError>)
    case callParticipantStartSpeaking(ChatResponse<CallParticipant>)
    case callParticipantStopSpeaking(ChatResponse<CallParticipant>)
    case callsToJoin(ChatResponse<[Call]>)
    case sticker(ChatResponse<StickerResponse>)
    case maxVideoSessionLimit(ChatResponse<CallParticipant>)
    case activeCallParticipants(ChatResponse<[CallParticipant]>)
    case callInquery(ChatResponse<[CallParticipant]>)
    case renewCall(ChatResponse<CreateCall>)
    case history(ChatResponse<[Call]>)
}
