//
// GeneralSubjectIdRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct GeneralSubjectIdRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol, Sendable {
    public var _subjectId: Int
    public let uniqueId: String
    public var typeCodeIndex: Index

    public init(subjectId: Int, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self._subjectId = subjectId
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }

    internal init(subjectId: Int, uniqueId: String, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self._subjectId = subjectId
        self.uniqueId = uniqueId
        self.typeCodeIndex = typeCodeIndex
    }

    private enum CodingKeys: CodingKey {
        case _subjectId
        case uniqueId
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self._subjectId, forKey: ._subjectId)
        try container.encodeIfPresent(self.uniqueId, forKey: .uniqueId)
    }
}
