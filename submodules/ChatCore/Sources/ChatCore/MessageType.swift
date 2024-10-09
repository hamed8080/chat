//
// MessageType.swift
// Copyright (c) 2022 ChatCore
//
// Created by Hamed Hosseini on 12/16/22

import Additive
import Foundation

public enum MessageType: Int, Codable, SafeDecodable, Identifiable, CaseIterable {
    public var id: Self { self }
    case text = 1
    case voice = 2
    case picture = 3
    case video = 4
    case sound = 5
    case file = 6
    case podSpacePicture = 7
    case podSpaceVideo = 8
    case podSpaceSound = 9
    case podSpaceVoice = 10
    case podSpaceFile = 11
    case link = 12
    case endCall = 13
    case startCall = 14
    case sticker = 15
    case location = 16
    case participantJoin = 18
    case participantLeft = 19

    /// Only when can't decode a type.
    ///
    /// Do not remove or move this property to the top of the enum, it must be the last enum because it uses ``SafeDecodable`` to decode the last item if no match found.
    case unknown
}
