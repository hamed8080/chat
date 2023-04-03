//
// InviteeTypes.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/2/22

import Additive
import Foundation

public enum InviteeTypes: Int, Codable, SafeDecodable {
    case ssoId = 1
    case contactId = 2
    case cellphoneNumber = 3
    case username = 4
    case userId = 5
    case coreUserId = 6

    /// Only when can't decode a type.
    ///
    /// Do not remove or move this property to the top of the enum, it must be the last enum because it uses ``SafeDecodable`` to decode the last item if no match found.
    case unknown
}
