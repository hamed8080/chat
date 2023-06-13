//
// UserEventTypes.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/2/22

import ChatCore
import ChatModels
import Foundation

public enum UserEventTypes {
    case roles(ChatResponse<[Roles]>)
    case user(ChatResponse<User>)
    case setProfile(ChatResponse<Profile>)
    case remove(ChatResponse<[UserRole]>)
}
