//
// UniqueIdManagerRequest.swift
// Copyright (c) 2022 ChatCore
//
// Created by Hamed Hosseini on 12/16/22

import Foundation

open class UniqueIdManagerRequest {
    public var uniqueId: String
    public var isAutoGenratedUniqueId = false
    public var chatTypeCodeIndex: TypeCodeIndexProtocol.Index

    public init(uniqueId: String? = nil, chatTypeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        isAutoGenratedUniqueId = uniqueId == nil
        self.chatTypeCodeIndex = chatTypeCodeIndex
        self.uniqueId = uniqueId ?? UUID().uuidString
    }
}
