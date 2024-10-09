//
// CallClientErrorRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/16/22

import Foundation

public struct CallClientErrorRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol {
    public let code: CallClientErrorType
    public let callId: Int
    public let uniqueId: String
    public var typeCodeIndex: Index

    public init(callId: Int, code: CallClientErrorType, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.callId = callId
        self.code = code
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }

    private enum CodingKeys: String, CodingKey {
        case code
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(code.rawValue, forKey: .code)
    }
}
