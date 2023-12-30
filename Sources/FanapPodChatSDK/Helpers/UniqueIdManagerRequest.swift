//
// UniqueIdManagerRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/16/22

import Foundation
public class UniqueIdManagerRequest {
    public var uniqueId: String
    public var isAutoGenratedUniqueId = false
    public var typeCodeIndex: TypeCodeIndexProtocol.Index

    public init(uniqueId: String? = nil, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        isAutoGenratedUniqueId = uniqueId == nil
        self.typeCodeIndex = typeCodeIndex
        self.uniqueId = uniqueId ?? UUID().uuidString
    }
}
