//
// CallEventTypes.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

public enum CallEventTypes {
    case callCreate(CreateCall)
    case callStarted(StartCall)
    case callReceived(CreateCall)
    case callDelivered(Call)
    case callEnded(Int?)
    case callCanceled(Call)
    case groupCallCanceled(CancelGroupCall)
    case callRejected(CreateCall)
    case startCallRecording(Participant)
    case stopCallRecording(Participant)
    case callParticipantJoined([CallParticipant])
    case callParticipantLeft([CallParticipant])
    case callParticipantMute([CallParticipant])
    case callParticipantUnmute([CallParticipant])
    case callParticipantsRemoved([CallParticipant])
    case turnVideoOn([CallParticipant])
    case turnVideoOff([CallParticipant])
    case callClientError(CallError)
    case callParticipantStartSpeaking(CallParticipant)
    case callParticipantStopSpeaking(CallParticipant)
    case sticker(StickerResponse)
}
