//
// ChatCore.UniqueIdProtocol+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatCore
import ChatDTO

public extension ChatCore.UniqueIdProtocol where Self: ChatDTO.UniqueIdProtocol {
    /// Never genetrate uniqueId here it will leads to response problem beacuse of different uniqueId.
    var chatUniqueId: String { uniqueId }
}
