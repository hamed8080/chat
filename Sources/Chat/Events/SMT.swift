//
// SMT.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/2/22

import Additive
import Foundation

public enum SMT: Int, Codable, CaseIterable, Identifiable, SafeDecodable {
    public var id: Self { self }
    case isTyping = 1
    case recordVoice = 2
    case uploadPicture = 3
    case uploadVideo = 4
    case uploadSound = 5
    case uploadFile = 6
    case serverTime = -1
    case unknown
}
