//
// AddRemoveParticipant+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatCore
import ChatDTO

public extension AddRemoveParticipant {
    var requestTypeEnum: ChatMessageVOTypes? { ChatMessageVOTypes(rawValue: requestType ?? ChatMessageVOTypes.unknown.rawValue) }
}
