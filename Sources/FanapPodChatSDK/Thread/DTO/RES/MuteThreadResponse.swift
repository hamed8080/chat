//
// MuteThreadResponse.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public struct MuteThreadResponse: Decodable {
    public var threadId: Int?
}

public typealias UnMuteThreadResponse = MuteThreadResponse
