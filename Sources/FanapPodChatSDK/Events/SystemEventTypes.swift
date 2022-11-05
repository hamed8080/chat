//
// SystemEventTypes.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

public enum SystemEventTypes {
    case systemMessage(message: SystemEventMessageModel, time: Int, id: Int?)
    case serverTime(Int)
}
