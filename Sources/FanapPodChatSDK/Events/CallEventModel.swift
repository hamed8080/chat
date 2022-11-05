//
// CallEventModel.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

open class CallEventModel {
    public let type: CallEventType

    public init(type: CallEventType) {
        self.type = type
    }
}

public enum CallEventType {
    case callCreate(CreateCall)
    case callStarted(StartCall)
    case callReceived(CreateCall)
    case callDelivered(Call)
    case callEnded(Int?)
    case callCanceled(Call)
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
}
