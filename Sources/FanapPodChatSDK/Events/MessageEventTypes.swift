//
// MessageEventTypes.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

public enum MessageEventTypes {
    case messageNew(Message)
    case messageSent(MessageResponse)
    case messageDelivery(MessageResponse)
    case messageSeen(MessageResponse)
    case messageEdit(Message)
    case messageDelete(Message)
}
