//
// CallEventTypes.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

public enum CallEventTypes {
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
    case callClientError(ChatResponse<CallError>)
    case callParticipantStartSpeaking(ChatResponse<CallParticipant>)
    case callParticipantStopSpeaking(ChatResponse<CallParticipant>)
    case callsToJoin(ChatResponse<[Call]>)
    case sticker(ChatResponse<StickerResponse>)
}
