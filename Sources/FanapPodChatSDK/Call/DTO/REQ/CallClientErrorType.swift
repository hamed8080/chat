//
// CallClientErrorType.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public enum CallClientErrorType: Int, Codable {
    case microphoneNotAvailable = 3000
    case cameraNotAvailable = 3001
}