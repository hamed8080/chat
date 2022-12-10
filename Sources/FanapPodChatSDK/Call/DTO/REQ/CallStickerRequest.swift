//
// CallStickerRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

public enum CallSticker: String, Codable, CaseIterable {
    case raiseHand = "raise_hand"
    case like
    case dislike
    case clap
    case heart
    case happy
    case angry
    case cry
    case power
    case bored
}

public class CallStickerRequest: UniqueIdManagerRequest, ChatSendable, SubjectProtocol {
    let callId: Int
    let stickers: [CallSticker]
    var subjectId: Int { callId }
    var content: String? { stickers.convertCodableToString() }
    var chatMessageType: ChatMessageVOTypes = .callStickerSystemMessage

    public init(callId: Int, stickers: [CallSticker], uniqueId: String? = nil) {
        self.callId = callId
        self.stickers = stickers
        super.init(uniqueId: uniqueId)
    }
}
