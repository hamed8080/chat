//
// CreateCallThreadRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22

import ChatDTO
import Foundation
import ChatModels

public extension ClientDTO {
    var toCallParticipant: CallParticipant {
        CallParticipant(sendTopic: topicSend,
                        userId: userId,
                        clientId: clientId,
                        mute: mute,
                        video: video)
    }
}
