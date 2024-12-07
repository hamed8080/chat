//
// AssistantAction.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatModels

public struct AssistantAction: Decodable, Identifiable, Equatable, Sendable {
    public var id = UUID().uuidString
    public var actionName: String?
    public var actionTime: UInt?
    public var actionType: AssistantActionTypes?
    public var participant: Participant?
    
    public init(id: String = UUID().uuidString,
                actionName: String? = nil,
                actionTime: UInt? = nil,
                actionType: AssistantActionTypes? = nil,
                participant: Participant? = nil
    ) {
        self.id = id
        self.actionName = actionName
        self.actionTime = actionTime
        self.actionType = actionType
        self.participant = participant
    }
    
    private enum CodingKeys: String, CodingKey {
        case actionName
        case actionTime
        case actionType
        case participantVO
    }
    
    public init(from decoder: Decoder) throws {
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        actionName = try container?.decodeIfPresent(String.self, forKey: .actionName)
        actionTime = try container?.decodeIfPresent(UInt.self, forKey: .actionTime)
        actionType = try container?.decodeIfPresent(AssistantActionTypes.self, forKey: .actionType)
        participant = try container?.decodeIfPresent(Participant.self, forKey: .participantVO)
    }
}
