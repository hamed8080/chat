//
// SystemEventTypes.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/2/22

import ChatCore
import ChatDTO
import Foundation

public enum SystemEventTypes {
    case systemMessage(ChatResponse<SystemEventMessageModel>)
    case serverTime(ChatResponse<Int?>)
}
