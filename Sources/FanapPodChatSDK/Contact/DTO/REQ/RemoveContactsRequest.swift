//
// RemoveContactsRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public class RemoveContactsRequest: UniqueIdManagerRequest, Encodable, BodyRequestProtocol {
    public let contactId: Int
    internal var typeCode: String?

    public init(contactId: Int, uniqueId _: String? = nil) {
        self.contactId = contactId
        super.init(uniqueId: nil)
    }

    private enum CodingKeys: String, CodingKey {
        case contactId = "id"
        case typeCode
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(contactId, forKey: .contactId)
        try? container.encodeIfPresent(typeCode, forKey: .typeCode)
    }
}
