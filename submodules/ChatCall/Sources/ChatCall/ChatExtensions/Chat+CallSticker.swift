//
// Chat+CallSticker.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

import Foundation
import Chat
import ChatDTO
import ChatCore
import ChatModels
import Async

// Request
public extension ChatImplementation {
    /// Send a sticker during the call..
    /// - Parameters:
    ///   - request: The callId and a sticker.
    func sendCallSticker(_ request: CallStickerRequest) {
        prepareToSendAsync(req: request, type: .callStickerSystemMessage)
    }
}

// Response
extension ChatImplementation {
    func onCallSticker(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<StickerResponse> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .call(.sticker(response)))
    }
}
