//
// StickerResponse.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public class StickerResponse: Decodable {
    public var callId: Int?
    public let sticker: CallSticker
    public let participant: Participant

    enum CodingKeys: String, CodingKey {
        case sticker = "stickerCode"
        case participant = "participantVO"
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        participant = try container.decode(Participant.self, forKey: .participant)
        sticker = try container.decode(CallSticker.self, forKey: .sticker)
    }
}
