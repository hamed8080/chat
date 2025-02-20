//
// CallHistoryClass.swift
// Copyright (c) 2022 ChatCache
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatModels

public class CallHistoryClass: NSObject, Codable {
    public var id: Int?
    public var creatorId: Int?
    public var type: CallType?
    public var createTime: UInt?
    public var startTime: UInt?
    public var endTime: UInt?
    public var status: CallStatus?
    public var isGroup: Bool?
    
    public init(
        id: Int?,
        creatorId: Int?,
        type: CallType?,
        createTime: UInt?,
        startTime: UInt?,
        endTime: UInt?,
        status: CallStatus?,
        isGroup: Bool?
    ) {
        self.id = id
        self.creatorId = creatorId
        self.type = type
        self.createTime = createTime
        self.startTime = startTime
        self.endTime = endTime
        self.status = status
        self.isGroup = isGroup
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case creatorId
        case type
        case createTime
        case startTime
        case endTime
        case status
        case isGroup
    }
    
    required public init(from decoder: Decoder) throws {
        guard let container = try? decoder.container(keyedBy: CodingKeys.self) else { return }
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        creatorId = try container.decodeIfPresent(Int.self, forKey: .creatorId)
        type = try container.decodeIfPresent(CallType.self, forKey: .type)
        createTime = try container.decodeIfPresent(UInt.self, forKey: .createTime)
        startTime = try container.decodeIfPresent(UInt.self, forKey: .startTime)
        endTime = try container.decodeIfPresent(UInt.self, forKey: .endTime)
        status = try container.decodeIfPresent(CallStatus.self, forKey: .status)
        isGroup = try container.decodeIfPresent(Bool.self, forKey: .isGroup)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(creatorId, forKey: .creatorId)
        try container.encodeIfPresent(type, forKey: .type)
        try container.encodeIfPresent(createTime, forKey: .createTime)
        try container.encodeIfPresent(startTime, forKey: .startTime)
        try container.encodeIfPresent(endTime, forKey: .endTime)
        try container.encodeIfPresent(status, forKey: .status)
        try container.encodeIfPresent(isGroup, forKey: .isGroup)
    }
}

public extension CallHistory {
    var toClass: CallHistoryClass {
        let callHistory = CallHistoryClass(id: id,
                                           creatorId: creatorId,
                                           type: type,
                                           createTime: createTime,
                                           startTime: startTime,
                                           endTime: endTime,
                                           status: status,
                                           isGroup: isGroup)
        return callHistory
    }
}

public extension CallHistoryClass {
    var toStruct: CallHistory {
        let callHistory = CallHistory(id: id,
                                      creatorId: creatorId,
                                      type: type,
                                      createTime: createTime,
                                      startTime: startTime,
                                      endTime: endTime,
                                      status: status,
                                      isGroup: isGroup)
        return callHistory
    }
}
