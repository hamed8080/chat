//
// CDReactionCountList+CoreDataProperties.swift
// Copyright (c) 2022 ChatCache
//
// Created by Hamed Hosseini on 12/14/22

import CoreData
import Foundation
import ChatModels
import Additive

public extension CDReactionCountList {
    typealias Entity = CDReactionCountList
    typealias Model = ReactionCountList
    typealias Id = NSNumber
    static let name = "CDReactionCountList"
    static let queryIdSpecifier: String = "%@"
    static let idName = "messageId"
}

public extension CDReactionCountList {
    @NSManaged var messageId: NSNumber?
    @NSManaged var reactionCounts: Data?
}

public extension CDReactionCountList {
    func update(_ model: Model) {
        messageId = model.messageId as? NSNumber ?? messageId
        reactionCounts = model.reactionCounts.data ?? reactionCounts
    }

    var codable: Model {
        var decodededReactionCount: [ReactionCount]?
        if let data = reactionCounts, let roles = try? JSONDecoder.instance.decode([ReactionCount].self, from: data) {
            decodededReactionCount = roles
        }
        return ReactionCountList(messageId: messageId?.intValue, reactionCounts: decodededReactionCount, userReaction: nil)
    }
}
