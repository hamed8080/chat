//
// MessageEventTypes.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/3/22

import Foundation

public enum MessageEventTypes {
    case messageNew(ChatResponse<Message>)
    case messageSent(ChatResponse<MessageResponse>)
    case messageDelivery(ChatResponse<MessageResponse>)
    case messageSeen(ChatResponse<MessageResponse>)
    case messageEdit(ChatResponse<Message>)
    case messageDelete(ChatResponse<Message>)
}
