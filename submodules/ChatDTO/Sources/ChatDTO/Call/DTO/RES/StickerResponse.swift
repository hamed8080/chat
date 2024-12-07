//
// StickerResponse.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/16/22

import Foundation
import ChatModels

public struct StickerResponse: Decodable, Sendable {
    public var callId: Int?
    public let sticker: CallSticker
    public let participant: Participant

    private enum CodingKeys: String, CodingKey {
        case sticker = "stickerCode"
        case participant = "participantVO"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        participant = try container.decode(Participant.self, forKey: .participant)
        sticker = try container.decode(CallSticker.self, forKey: .sticker)
    }
}
