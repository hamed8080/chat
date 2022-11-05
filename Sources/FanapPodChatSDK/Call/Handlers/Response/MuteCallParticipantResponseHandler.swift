//
// MuteCallParticipantResponseHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

class MuteCallParticipantResponseHandler {
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        let chat = Chat.sharedInstance
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let callParticipants = try? JSONDecoder().decode([CallParticipant].self, from: data) else { return }
        chat.delegate?.chatEvent(event: .call(CallEventModel(type: .callParticipantMute(callParticipants))))
        chat.callbacksManager.muteCallParticipantsDelegate?(callParticipants, chatMessage.uniqueId)
    }
}
