//
// SignalMessageType.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

//
//  SignalMessageType.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//
import Foundation

public enum SignalMessageType: Int, Encodable, SafeDecodable {
    case isTyping = 1
    case recordVoice = 2
    case uploadPicture = 3
    case uploadVideo = 4
    case uploadSound = 5
    case uploadFile = 6

    /// Only when can't decode a type.
    ///
    /// Do not remove or move this property to the top of the enum, it must be the last enum because it uses ``SafeDecodable`` to decode the last item if no match found.
    case unknown
}
