//
// MessageEventTypes.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/3/22

import ChatCore
import ChatDTO
import ChatModels
import Foundation

public enum MessageEventTypes {
    case history(ChatResponse<[Message]>)
    case messages(ChatResponse<[Message]>)
    case new(ChatResponse<Message>)
    case sent(ChatResponse<MessageResponse>)
    case delivered(ChatResponse<MessageResponse>)
    case seen(ChatResponse<MessageResponse>)
    case edited(ChatResponse<Message>)
    case deleted(ChatResponse<Message>)
    case cleared(ChatResponse<Int>)
    case queueTextMessages(ChatResponse<[SendTextMessageRequest]>)
    case queueEditMessages(ChatResponse<[EditMessageRequest]>)
    case queueForwardMessages(ChatResponse<[ForwardMessageRequest]>)
    case queueFileMessages(ChatResponse<[(UploadFileRequest, SendTextMessageRequest)]>)
    case pin(ChatResponse<Message>)
    case unpin(ChatResponse<Message>)
    case deliveredToParticipants(ChatResponse<[Participant]>)
    case seenByParticipants(ChatResponse<[Participant]>)
    case export(ChatResponse<URL>)
}
