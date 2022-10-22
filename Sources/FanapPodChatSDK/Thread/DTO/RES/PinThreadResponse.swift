//
// PinThreadResponse.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public struct PinThreadResponse: Decodable {
    public var threadId: Int?
}

public typealias UnPinThreadResponse = PinThreadResponse
