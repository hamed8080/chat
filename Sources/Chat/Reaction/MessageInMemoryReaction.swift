//
// MessageInMemoryReaction.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatModels
import ChatDTO

public class MessageInMemoryReaction {
    let messageId: Int
    var currentUserReaction: Reaction?
    var summary: [ReactionCount] = []
    /// All participants reaction to a message.
    var details: [Reaction] = []
    
    /// All participants in all reactions tab of your app
    ///
    /// This will store only request count and offset with a nil value in ``ChatDTO/ReactionListRequest.sticker``.
    /// We do this because getting right orders in all tab is different than other reaction tabs.
    ///>Important: If a reaction has been added or removed, the offset is invalid, so we have to request it from the server.
    ///
    var allDetails: [String: [Reaction]] = [:]

    public init(messageId: Int) {
        self.messageId = messageId
    }
    
    public func appendOrReplaceDetail(reactions: [Reaction], listRequest: ReactionListRequest) {
        if listRequest.sticker == nil {
            /// Add response to all details when the client requested all tabs without specifying the sticker.
            let requestKey = key(for: listRequest)
            allDetails[requestKey] = reactions
            
            /// Separate reactions by stickers and then append to nomarl sticker tabs
            /// to prevent requesting if it has reactions inside a sticker
            let groups = Dictionary(grouping: reactions, by: {$0.reaction?.rawValue})
            groups.forEach { groupKey, groupValue in
                groupValue.forEach { reaction in
                    if !details.contains(where: {$0.participant?.id == reaction.participant?.id}) {
                        details.append(reaction)
                    }
                }
            }
        } else {
            /// Add reactions to nomarl reactios cache if the user requested with sitcker
            reactions.forEach { reaction in
                if let index = self.details.firstIndex(where: {$0.id == reaction.id}) {
                    details[index] = reaction
                } else {
                    details.append(reaction)
                }
            }
        }
    }

    public func addOrReplaceSummaryCount(sticker: Sticker) {
        if let index = summary.firstIndex(where: { $0.sticker == sticker }) {
            summary[index].count = (summary[index].count ?? 0) + 1
        } else {
            summary.append(.init(sticker: sticker, count: 1))
        }
    }

    public func deleteSummaryCount(sticker: Sticker) {
        if let index = summary.firstIndex(where: { $0.sticker == sticker }) {
            summary[index].count = max(0, (summary[index].count ?? 0) - 1)
            if summary[index].count ?? 0 == 0 {
                summary.remove(at: index)
            }
        }
    }
    
    public func containsAllOffset(_ request: ReactionListRequest) -> [Reaction]? {
        let requestKey = key(for: request)
        return allDetails.first(where: {$0.key == requestKey})?.value
    }
    
    private func key(for request: ReactionListRequest) -> String {
        "\(request.count)-\(request.offset)"
    }
}
