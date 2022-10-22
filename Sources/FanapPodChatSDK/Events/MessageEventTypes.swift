//
// MessageEventTypes.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

public enum MessageEventTypes {
    case messageNew(Message)
    case messageSend(Message)
    case messageDelivery(Message)
    case messageSeen(Message)
    case messageEdit(Message)
    case messageDelete(Message)
}
