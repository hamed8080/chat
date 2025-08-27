//
// SendOfferSDPReq.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

import Chat
import Foundation
import Async
import ChatCore

struct SendOfferSDPReq: Codable, AsyncSnedable {
    let id: CallMessageType
    var brokerAddress: String
    var token: String
    var topic: String
    var sdpOffer: String
    private var mediaType: Mediatype
    private var useComedia = true
    private var useSrtp = false
    var chatId: Int?
    var peerName: String?
    var content: String? { jsonString }
    var asyncMessageType: AsyncMessageTypes? = .message

    public init(id: CallMessageType, peerName: String, brokerAddress: String, token: String, topic: String, sdpOffer: String, mediaType: Mediatype, chatId: Int?) {
        self.id = id
        self.peerName = peerName
        self.brokerAddress = brokerAddress
        self.token = token
        self.topic = topic
        self.sdpOffer = sdpOffer
        self.mediaType = mediaType
        self.chatId = chatId
    }
}

public enum Mediatype: Int, Codable {
    case audio = 1
    case video = 2
}
