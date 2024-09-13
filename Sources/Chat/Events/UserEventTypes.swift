//
// UserEventTypes.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/2/22

import ChatCore
import ChatModels
import Foundation

public enum UserEventTypes {
    case currentUserRoles(ChatResponse<[Roles]>)
    case setRolesToUser(ChatResponse<[UserRole]>)
    case user(ChatResponse<User>)
    case setProfile(ChatResponse<Profile>)
    case remove(ChatResponse<[UserRole]>)
}
