//
// Chat+TerminateCall.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

import Foundation
import Chat
import ChatDTO
import ChatModels

public protocol WebRTCActions {
    var callParticipantsUserRTC: [CallParticipantUserRTC] { get }
    func switchCamera()
    func unmuteCall(_ req: UNMuteCallRequest)
    func muteCall(_ req: MuteCallRequest)
    func toggleSpeaker()
    func reCalculateActiveVideoSessionLimit()
    func turnOffVideoCall(callId: Int)
    func turnOnVideoCall(callId: Int)
    func addCallParticipants(_ callParticipants: [CallParticipant])
}

public protocol CallProtocol: WebRTCActions {
    /// Accept a received call.
    /// - Parameters:
    ///   - request: The request that contains a callId and how do you want to answer the call as an example with audio or video.
    func acceptCall(_ request: AcceptCallRequest)

    /// List of active call participants during the call.
    /// - Parameters:
    ///   - request: The callId of the call.
    func activeCallParticipants(_ request: GeneralSubjectIdRequest)

    /// Add a new participant to a thread during the call.
    /// - Parameters:
    ///   - request: A List of people with userNames or contactIds beside a callId.
    func addCallPartcipant(_ request: AddCallParticipantsRequest)

    /// To get the status of the call and participants after a disconnect or when you need it.
    /// - Parameters:
    ///   - request: The callId.
    func callInquery(_ request: GeneralSubjectIdRequest)

    /// A request to start recording a call.
    /// - Parameters:
    ///   - request: The callId of the call.
    func startRecording(_ request: GeneralSubjectIdRequest)

    /// A request to stop recording a call.
    /// - Parameters:
    ///   - request: The callId of the call.
    func stopRecording(_ request: GeneralSubjectIdRequest)

    /// List of the call history.
    /// - Parameters:
    ///   - request: The request that contains offset and count and some other filters.
    func callsHistory(_ request: CallsHistoryRequest)

    /// Send a sticker during the call..
    /// - Parameters:
    ///   - request: The callId and a sticker.
    func sendCallSticker(_ request: CallStickerRequest)

    /// A list of calls that is currnetly is running and you could join to them.
    /// - Parameters:
    ///   - request: List of threads that you are in and more filters.
    func getCallsToJoin(_ request: GetJoinCallsRequest)

    /// The cancelation of a call when nobody answer the call or somthing different happen.
    /// - Parameters:
    ///   - request: A call that you want to cancel a call.
    func cancelCall(_ request: CancelCallRequest)

    /// Mute the voice during the conversation.
    /// - Parameters:
    ///   - request: The callId that you want to turn the microphone off.
    func muteCall(_ request: MuteCallRequest)

    /// UNMute the voice during the conversation.
    /// - Parameters:
    ///   - request: The callId that you want to turn the microphone on.
    func unmuteCall(_ request: UNMuteCallRequest)

    /// Turn on the camera during the conversation.
    /// - Parameters:
    ///   - request: The callId that you want to turn the camera on.
    func turnOnVideoCall(_ request: GeneralSubjectIdRequest)

    /// Turn off the camera during the conversation.
    /// - Parameters:
    ///   - request: The callId that you want to turn the camera off.
    func turnOffVideoCall(_ request: GeneralSubjectIdRequest)

    /// To terminate a call.
    /// - Parameters:
    ///   - request: A request with a callId to finish the current call.
    func endCall(_ request: GeneralSubjectIdRequest)

    /// Remove a participant from a call if you have access.
    /// - Parameters:
    ///   - request: The request that contains a callId and llist of user to remove from a call.
    func removeCallPartcipant(_ request: RemoveCallParticipantsRequest)

    /// To renew  a call you could start request it by this method.
    /// - Parameters:
    ///   - request: The callId and list of the participants.
    func renewCallRequest(_ request: RenewCallRequest)

    /// A request that shows some errors has happened on the client side during the call for example maybe the user doesn't have access to the camera when trying to turn it on.
    /// - Parameters:
    ///   - request: The code of the error and a callId.
    func sendCallClientError(_ request: CallClientErrorRequest)

    /// Start request a call.
    /// - Parameters:
    ///   - request: The request to how to start the call as an example start call with a threadId.
    func requestCall(_ request: StartCallRequest)

    /// Start a group call with list of people or a threadId.
    /// - Parameters:
    ///   - request: A request that contains a list of people or a threadId.
    func requestGroupCall(_ request: StartCallRequest)

    /// Terminate the call completely for all the participants at once if you have access to it.
    /// - Parameters:
    ///   - request: The callId of the call to terminate.
    func terminateCall(_ request: GeneralSubjectIdRequest)

    /// Only for previewing the current state of the application in swiftUI.
    func preview(startCall: StartCall)
}

public extension CallProtocol {
    /// Accept a received call.
    /// - Parameters:
    ///   - request: The request that contains a callId and how do you want to answer the call as an example with audio or video.
    func acceptCall(_ request: AcceptCallRequest) {
        acceptCall(request)
    }

    /// List of active call participants during the call.
    /// - Parameters:
    ///   - request: The callId of the call.
    func activeCallParticipants(_ request: GeneralSubjectIdRequest) {
        activeCallParticipants(request)
    }

    /// Add a new participant to a thread during the call.
    /// - Parameters:
    ///   - request: A List of people with userNames or contactIds beside a callId.
    func addCallPartcipant(_ request: AddCallParticipantsRequest) {
        addCallPartcipant(request)
    }

    /// To get the status of the call and participants after a disconnect or when you need it.
    /// - Parameters:
    ///   - request: The callId.
    func callInquery(_ request: GeneralSubjectIdRequest) {
        callInquery(request)
    }

    /// A request to start recording a call.
    /// - Parameters:
    ///   - request: The callId of the call.
    func startRecording(_ request: GeneralSubjectIdRequest) {
        startRecording(request)
    }

    /// A request to stop recording a call.
    /// - Parameters:
    ///   - request: The callId of the call.
    func stopRecording(_ request: GeneralSubjectIdRequest) {
        stopRecording(request)
    }

    /// List of the call history.
    /// - Parameters:
    ///   - request: The request that contains offset and count and some other filters.
    func callsHistory(_ request: CallsHistoryRequest) {
        callsHistory(request)
    }

    /// Send a sticker during the call..
    /// - Parameters:
    ///   - request: The callId and a sticker.
    func sendCallSticker(_ request: CallStickerRequest) {
        sendCallSticker(request)
    }

    /// A list of calls that is currnetly is running and you could join to them.
    /// - Parameters:
    ///   - request: List of threads that you are in and more filters.
    func getCallsToJoin(_ request: GetJoinCallsRequest) {
        getCallsToJoin(request)
    }

    /// The cancelation of a call when nobody answer the call or somthing different happen.
    /// - Parameters:
    ///   - request: A call that you want to cancel a call.
    func cancelCall(_ request: CancelCallRequest) {
        cancelCall(request)
    }

    /// Mute the voice during the conversation.
    /// - Parameters:
    ///   - request: The callId that you want to turn the microphone off.
    func muteCall(_ request: MuteCallRequest) {
        muteCall(request)
    }

    /// UNMute the voice during the conversation.
    /// - Parameters:
    ///   - request: The callId that you want to turn the microphone on.
    func unmuteCall(_ request: UNMuteCallRequest) {
        unmuteCall(request)
    }

    /// Turn on the camera during the conversation.
    /// - Parameters:
    ///   - request: The callId that you want to turn the camera on.
    func turnOnVideoCall(_ request: GeneralSubjectIdRequest) {
        turnOnVideoCall(request)
    }

    /// Turn off the camera during the conversation.
    /// - Parameters:
    ///   - request: The callId that you want to turn the camera off.
    func turnOffVideoCall(_ request: GeneralSubjectIdRequest) {
        turnOffVideoCall(request)
    }

    /// To terminate a call.
    /// - Parameters:
    ///   - request: A request with a callId to finish the current call.
    func endCall(_ request: GeneralSubjectIdRequest) {
        endCall(request)
    }

    /// Remove a participant from a call if you have access.
    /// - Parameters:
    ///   - request: The request that contains a callId and llist of user to remove from a call.
    func removeCallPartcipant(_ request: RemoveCallParticipantsRequest) {
        removeCallPartcipant(request)
    }

    /// To renew  a call you could start request it by this method.
    /// - Parameters:
    ///   - request: The callId and list of the participants.
    func renewCallRequest(_ request: RenewCallRequest) {
        renewCallRequest(request)
    }

    /// A request that shows some errors has happened on the client side during the call for example maybe the user doesn't have access to the camera when trying to turn it on.
    /// - Parameters:
    ///   - request: The code of the error and a callId.
    func sendCallClientError(_ request: CallClientErrorRequest) {
        sendCallClientError(request)
    }

    /// Start request a call.
    /// - Parameters:
    ///   - request: The request to how to start the call as an example start call with a threadId.
    func requestCall(_ request: StartCallRequest) {
        requestCall(request)
    }

    /// Start a group call with list of people or a threadId.
    /// - Parameters:
    ///   - request: A request that contains a list of people or a threadId.
    func requestGroupCall(_ request: StartCallRequest) {
        requestGroupCall(request)
    }

    /// Terminate the call completely for all the participants at once if you have access to it.
    /// - Parameters:
    ///   - request: The callId of the call to terminate.
    ///   - completion: List of call participants that change during the request.
    func terminateCall(_ request: GeneralSubjectIdRequest) {
        terminateCall(request)
    }
}

extension ChatImplementation: CallProtocol {}

public extension ChatImplementation {
    var callParticipantsUserRTC: [CallParticipantUserRTC] {
        ChatCall.instance?.webrtc?.callParticipantsUserRTC ?? []
    }

    func switchCamera() {

    }

    func toggleSpeaker() {

    }

    func reCalculateActiveVideoSessionLimit() {

    }

    func turnOffVideoCall(callId: Int) {

    }

    func turnOnVideoCall(callId: Int) {

    }

    func addCallParticipants(_ callParticipants: [ChatModels.CallParticipant]) {

    }
}

public extension ChatManager {
    static var call: CallProtocol? {
        activeInstance as? CallProtocol
    }
}
