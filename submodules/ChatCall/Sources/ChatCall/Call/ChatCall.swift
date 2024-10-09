//
// ChatCall.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

import Foundation
import Additive
import Chat
import Async

public class ChatCall: CallMessageProtocol {
    private init(){}
    
    public static var instance: ChatCall? = ChatCall()

    var callStartTimer: TimerProtocol?
    var callState: CallState?
    public var webrtc: WebRTCClient?
    public var callDelegate: WebRTCClientDelegate?

    init(callStartTimer: TimerProtocol = Timer(), callDelegate: WebRTCClientDelegate? = nil) {
        self.callStartTimer = callStartTimer
        self.callDelegate = callDelegate
    }

    public func onCallMessageDelegate(asyncMessage: AsyncMessage, chat: ChatImplementation) {
        let message = asyncMessage.chatMessage
        switch message?.type {
        case .acceptCall, .endCallRequest, .addCallParticipant, .terminateCall:
            // - TODO: Not impelemented by the ChatCall SDK
            break
        case .startCallRequest, .groupCallRequest:
            chat.onStartCall(asyncMessage)
            break
        case .cancelCall:
            chat.onCancelCall(asyncMessage)
            break
        case .deliveredCallRequest:
            chat.onDeliverCall(asyncMessage)
            break
        case .callStarted:
            chat.onCallStarted(asyncMessage)
            break
        case .endCall:
            chat.onCallEnded(asyncMessage)
            break
        case .getCalls:
            chat.onCallsHistory(asyncMessage)
            break
        case .leaveCall:
            chat.onCallParticipantLeft(asyncMessage)
            break
        case .callParticipantJoined:
            chat.onJoinCallParticipant(asyncMessage)
            break
        case .removeCallParticipant:
            chat.onRemoveCallParticipant(asyncMessage)
            break
        case .muteCallParticipant:
            chat.onMute(asyncMessage)
            break
        case .unmuteCallParticipant:
            chat.onUNMute(asyncMessage)
            break
        case .cancelGroupCall:
            chat.onGroupCallCanceled(asyncMessage)
            break
        case .activeCallParticipants:
            chat.onActiveCallParticipants(asyncMessage)
            break
        case .callSessionCreated:
            chat.onCallSessionCreated(asyncMessage)
            break
        case .turnOnVideoCall:
            chat.onVideoTurnedOn(asyncMessage)
        case .turnOffVideoCall:
            chat.onVideoTurnedOff(asyncMessage)
            break
        case .startRecording:
            chat.onCallRecordingStarted(asyncMessage)
            break
        case .stopRecording:
            chat.onCallRecordingStopped(asyncMessage)
            break
        case .getCallsToJoin:
            chat.onJoinCalls(asyncMessage)
            break
        case .callClientErrors:
            chat.onCallError(asyncMessage)
            break
        case .callStickerSystemMessage:
            chat.onCallSticker(asyncMessage)
            break
        case .renewCallRequest:
            chat.onRenewCall(asyncMessage)
            break
        case .callInquiry:
            chat.onCallInquiry(asyncMessage)
            break
        default:
            break
        }
    }

}
