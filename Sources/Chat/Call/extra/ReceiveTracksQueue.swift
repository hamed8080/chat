//
// ReceiveTracksQueue.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

import WebRTC

/// This class is responsible to open a receive tracks one by one for audio, video or screen share.
///
/// This class will do things in order like below:
///
/// 1- It will first receive **RECEIVING_MEDIA** and push them to the queue.
///
/// 2- Then it will send a request with type of **SUBSCRIBE** for the first request.
///
/// 3- Later on, the Call server will raise a **PROCESS_SDP_OFFER** event,
///    then, we will set it to our receive peer connection and create an **answer**
///    and set it to our receive peer connection with setLocalDescription method.
///
/// 4- We send a request for this answer with **RECIVE_SDP_ANSWER**.
///
/// 6- The the server will raise another respone for it with type of **JOIN_AADDITIONN_COMPLETE** or
///    **JOIN_DELETION_COMPLETE**.
///
/// 7- We use this response to remove the queued item and start processing the next item and do 1-7 again.
@ChatGlobalActor
class ReceiveTracksQueue {
    private var items: [ReceiveMediaItem] = []
    weak var peerManager: RTCPeerConnectionManager?
    var chat: ChatInternalProtocol?
    private var subscribed = false
    private var isNegotiating: Bool { inNegotiation != nil }
    private var inNegotiation: (topic: String, item: ReceiveMediaItem)?
    var brokerAddress: String = ""
    
    private var delegate: ChatDelegate? { chat?.delegate }
    
    init() {}
    
    func enqueue(item: ReceiveMediaItem) {
        self.items.append(item)
        if !isNegotiating {
            Task {
                do {
                    try await dequeue(item: item)
                } catch {
                    print("Failed to negotaite the receive media item: \(item.topic)")
                }
            }
        }
    }
    
    private func dequeue(item: ReceiveMediaItem) async throws {
        let id: CallMessageType = subscribed ? .update : .subscribe
        let mid = subscribed ? 0 : 1
        
        let req = CallSubscribeRequest(
            brokerAddress: brokerAddress,
            addition: [item.toAddition]
        )
        
        subscribed = true
        _ = peerManager?.sendAsyncMessage(req, id)
        inNegotiation = (item.topic, item)
    }
    
    public func onJoinAdditionComplete(_ resp: JoinAdditionCompleteRes) {
        resp.topic.forEach { addition in
            clearOldNegotiation(topic: addition.topic)
        }

        if let next = items.first {
            Task {
                try await dequeue(item: next)
            }
        }
    }
    
    private func clearOldNegotiation(topic: String) {
        if inNegotiation?.topic == topic {
            items.removeAll(where: { $0.topic == inNegotiation?.item.topic })
            inNegotiation = nil
        }
    }
}
