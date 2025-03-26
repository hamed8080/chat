//
// CallStickerRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22

import ChatDTO
import ChatCore
import Foundation

extension CallStickerRequest: @retroactive ChatSendable, @retroactive SubjectProtocol {}

public extension CallStickerRequest {
    var subjectId: Int { callId }
    var content: String? { stickers.jsonString }
    var chatTypeCodeIndex: Index { typeCodeIndex }
}
