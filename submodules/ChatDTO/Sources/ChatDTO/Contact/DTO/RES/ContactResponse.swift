//
// ContactResponse.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatModels

public struct ContactResponse: Decodable, Sendable {
    public var hasError: Bool?
    public var referenceNumber: String?
    public var errorCode: Int?
    public var contentCount: Int = 0
    public var contacts: [Contact] = []
    
    private enum CodingKeys: String, CodingKey {
        case contentCount = "count"
        case contacts = "result"
        case hasError
        case referenceNumber
        case errorCode
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        hasError = try? container.decodeIfPresent(Bool.self, forKey: .hasError)
        referenceNumber = try? container.decodeIfPresent(String.self, forKey: .referenceNumber)
        if let contacts = try? container.decodeIfPresent([Contact].self, forKey: .contacts) ?? [] {
            self.contacts = contacts
        }
        contentCount = try container.decodeIfPresent(Int.self, forKey: .contentCount) ?? 0
        errorCode = try? container.decodeIfPresent(Int.self, forKey: .errorCode)
    }
    
    public init(contentCount: Int = 0,
                contacts: [Contact] = [],
                hasError: Bool? = nil,
                errorCode: Int? = nil,
                referenceNumber: String? = nil) {
        self.contentCount = contentCount
        self.contacts = contacts
        self.hasError = hasError
        self.errorCode = errorCode
        self.referenceNumber = referenceNumber
    }
}
