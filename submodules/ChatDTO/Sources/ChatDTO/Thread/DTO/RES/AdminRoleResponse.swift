//
// AdminRoleResponse.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatModels

public struct AdminRoleResponse: Decodable, Sendable {
    public let participant: Participant?
    public let hasError: Bool?
    public let errorMessage: String?
    public let roleName: String?

    private enum CodingKeys: CodingKey {
        case participantVO
        case hasError
        case errorMessage
        case roleName
    }

    public init(from decoder: Decoder) throws {
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        participant = try container?.decodeIfPresent(Participant.self, forKey: .participantVO)
        hasError = try container?.decodeIfPresent(Bool.self, forKey: .hasError)
        errorMessage = try container?.decodeIfPresent(String.self, forKey: .errorMessage)
        roleName = try container?.decodeIfPresent(String.self, forKey: .roleName)
    }

    public init(
        participant: Participant? = nil,
        hasError: Bool? = nil,
        errorMessage: String? = nil,
        roleName: String? = nil
    ) {
        self.participant = participant
        self.hasError = hasError
        self.errorMessage = errorMessage
        self.roleName = roleName
    }
}
