//
// SendTracksQueue.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

import WebRTC

/// This class is responsible to open a send track one by one for audio, video or screen share.
///
/// This class will do things in order like below:
///
/// 1- Create a SDP offer for the openned track.
///
/// 2- Set this SDP as the localDescription for the send peer connection.
///
/// 3- Send this as **SEND_SDP_OFFER** for the first openned track,
///    or **SEND_NEGOTIATION** if it is not the first time.
///
/// 4- Wait for the **PROCESS_SDP_ANSWER** from the server.
///
/// 5- Remove the queued sdp offer.
///
/// 6- Start opening another track and do 1-5 again.
@ChatGlobalActor
class SendTracksQueue {
    enum TrackType {
        case video
        case audio
        case screenShare
    }
    
    private var tracks: [TrackType] = []
    weak var peerManager: RTCPeerConnectionManager?
    weak var callContainer: CallContainer?
    var chat: ChatInternalProtocol?
    private var firstTime = true
    private var isNegotiating: Bool { inNegotiation != nil }
    private var inNegotiation: (uniqueId: String, type: TrackType)?
    private var userRTC: CallParticipantUserRTC?
    private var mid = 0
    
    private var delegate: ChatDelegate? { chat?.delegate }
    
    init() {}
    
    public func enqueue(trackType: TrackType) async throws {
        self.tracks.append(trackType)
        if !isNegotiating {
            try await dequeue(trackType: trackType)
        }
    }
    
    private func dequeue(trackType: TrackType) async throws {
        let id: CallMessageType = firstTime ? .sendSdpOffer : .sendNegotiation
        let mid = firstTime ? 0 : 1
        var req: SendOfferSDPReq?
        
        if trackType == .audio {
            req = try await openAudioTrack()
        } else if trackType == .video {
            req = try await openVideoTrack()
        }
        
        firstTime = false
        if let req = req, let uniqueId = peerManager?.sendAsyncMessage(req, id) {
            inNegotiation = (uniqueId, trackType)
        }
    }
    
    public func negotiationFinished(uniqueId: String) {
        clearOldNegotiation(uniqueId: uniqueId)
        
        if let next = tracks.first {
            Task {
                try await dequeue(trackType: next)
            }
        }
    }
    
    private func clearOldNegotiation(uniqueId: String) {
        if inNegotiation?.uniqueId == uniqueId {
            tracks.removeAll(where: { $0 == inNegotiation?.type })
            inNegotiation = nil
        }
    }
    
    public func startOpening(_ userRTC: CallParticipantUserRTC) {
        self.userRTC = userRTC
        Task {
            if userRTC.callParticipant.mute == false {
                try await enqueue(trackType: .audio)
            }
            
            if userRTC.callParticipant.video == true {
                try await enqueue(trackType: .video)
            }
        }
    }
    
    private func openAudioTrack() async throws -> SendOfferSDPReq? {
        guard let userRTC = userRTC, let peerManager = peerManager else { return nil }
        
        let track = peerManager.addSendAudioTrack(userRTC: userRTC)
        
        if let callContainer = callContainer, let index = callContainer.callParticipantsUserRTC.firstIndex(where: { $0.isMe }) {
            callContainer.callParticipantsUserRTC[index].audioTrack = track
            callContainer.callParticipantsUserRTC[index].callParticipant.mute = false
            callContainer.callParticipantsUserRTC[index].audioTrack?.isEnabled = true
        }
        
        delegate?.chatEvent(event: .call(.audioTrackAdded(track, userRTC.id)))
        return try await generateOffer(
            pc: peerManager,
            topic: userRTC.callParticipant.topics.topicAudio,
            mediaType: .audio
        )
    }
    
    private func openVideoTrack() async throws -> SendOfferSDPReq? {
        guard let userRTC = userRTC, let peerManager = peerManager else { return nil }
        
        let track = peerManager.addSendVideoTrack(userRTC: userRTC)
        if let callContainer = callContainer, let index = callContainer.callParticipantsUserRTC.firstIndex(where: { $0.isMe }) {
            callContainer.callParticipantsUserRTC[index].videoTrack = track
            callContainer.callParticipantsUserRTC[index].callParticipant.video = true
            callContainer.callParticipantsUserRTC[index].videoTrack?.isEnabled = true
        }
        
        delegate?.chatEvent(event: .call(.videoTrackAdded(track, userRTC.id)))
        return try await generateOffer(
            pc: peerManager,
            topic: userRTC.callParticipant.topics.topicVideo,
            mediaType: .video
        )
    }
    
    private func generateOffer(
        pc: RTCPeerConnectionManager,
        topic: String,
        mediaType: ReveiveMediaItemType
    ) async throws -> SendOfferSDPReq {
        let res = try await pc.generateSDPOfferForSendPeer(
            mediaType: mediaType,
            topic: topic,
            mline: mid
        )
        mid = mid + 1
        return res
    }
}
