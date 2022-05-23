//
//  CallEventModel.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation

open class CallEventModel {
    
    public let type: CallEventType
    
    public init(type: CallEventType) {
        self.type                 = type
    }
}

public enum CallEventType{
    case CALL_CREATE(CreateCall)
    case CALL_STARTED(StartCall)
    case CALL_RECEIVED(CreateCall)
    case CALL_DELIVERED(Call)
    case CALL_ENDED(Int?)
    case CALL_CANCELED(Call)
    case CALL_REJECTED(CreateCall)
    case START_CALL_RECORDING(Participant)
    case STOP_CALL_RECORDING(Participant)
    case CALL_PARTICIPANT_JOINED([CallParticipant])
    case CALL_PARTICIPANT_LEFT([CallParticipant])
    case CALL_PARTICIPANT_MUTE([CallParticipant])
    case CALL_PARTICIPANT_UNMUTE([CallParticipant])
    case CALL_PARTICIPANTS_REMOVED([CallParticipant])
    case TURN_VIDDEO_ON([CallParticipant])
    case TURN_VIDDEO_OFF([CallParticipant])
    case CALL_CLIENT_ERROR(CallError)
    case CALL_PARTICIPANT_START_SPEAKING(CallParticipant)
    case CALL_PARTICIPANT_STOP_SPEAKING(CallParticipant)
}
