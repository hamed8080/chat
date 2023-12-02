//
// UserEventTypes.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/2/22

import Foundation

public enum UserEventTypes {
    case roles(ChatResponse<[Roles]>)
    case onUser(ChatResponse<User>)
}