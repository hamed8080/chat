//
// SDPOfferNegotiationQueue.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

@ChatGlobalActor
class SDPOfferNegotiationQueue {
    private var queue: [SendOfferSDPReq] = []
    weak var peerManager: RTCPeerConnectionManager?
    private var firstTime = true
    private var isNegotiating: Bool = false
    private var inNegotiation: (uniqueId: String, req: SendOfferSDPReq)?
    
    init() {}
    
    public func enqueue(item: SendOfferSDPReq) {
        if firstTime {
            firstTime = false
            startNegotiation(item: item, id: .sendSdpOffer)
        } else if !isNegotiating {
            startNegotiation(item: item, id: .sendNegotiation)
        }
        self.queue.append(item)
    }
    
    private func startNegotiation(item: SendOfferSDPReq, id: CallMessageType) {
        isNegotiating = true
        if let uniqueId = peerManager?.sendAsyncMessage(item, id) {
            inNegotiation = (uniqueId, item)
        }
    }
    
    public func negotiationFinished(uniqueId: String) {
        clearOldNegotiation(uniqueId: uniqueId)
        
        if let next = queue.first {
            startNegotiation(item: next, id: .sendNegotiation)
        }
    }
    
    private func clearOldNegotiation(uniqueId: String) {
        isNegotiating = false
        if inNegotiation?.uniqueId == uniqueId {
            queue.removeAll(where: { inNegotiation?.req.addition.first?.topic == $0.addition.first?.topic })
            inNegotiation = nil
        }
    }
}


