//
// CallState.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
enum CallState: String {
    case requested
    case created
    case canceled
    case started
    case ended
    case initializeWebrtc
}
