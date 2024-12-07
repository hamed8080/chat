//
// ThreadsRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 11/19/22

import ChatDTO
import ChatCore
import Foundation
import ChatCache

extension ThreadsRequest: @retroactive ChatSendable {}

public extension ThreadsRequest {
    var content: String? { jsonString }
    var chatTypeCodeIndex: ChatCore.TypeCodeIndexProtocol.Index { typeCodeIndex }
}


public extension ThreadsRequest {
    var fetchRequest: FetchThreadRequest {
        .init(count: count,
              offset: offset,
              title: name,
              description: name,
              new: new,
              isGroup: isGroup,
              type: type?.rawValue,
              archived: archived,
              threadIds: threadIds,
              creatorCoreUserId: creatorCoreUserId,
              partnerCoreUserId: partnerCoreUserId,
              partnerCoreContactId: partnerCoreContactId,
              metadataCriteria: metadataCriteria,
              uniqueId: uniqueId)
    }

    init(searchText: String, count: Int = 25, offset: Int = 0, new: Bool? = nil) {
        let text = searchText.lowercased()
        var name: String? = nil
        var cellPhoneNumber: String? = nil
        var userName: String? = nil
        if text.lowercased().contains("tel:") {
            let startIndex = text.index(text.startIndex, offsetBy: 4)
            cellPhoneNumber = String(text[startIndex..<text.endIndex])
        } else if text.lowercased().contains("uname:") {
            let startIndex = text.index(text.startIndex, offsetBy: 6)
            userName = String(text[startIndex..<text.endIndex])
        } else {
            name = text
        }
        name = searchText.isEmpty ? nil : name
        self = ThreadsRequest(count: count, offset: offset, name: name, new: new, cellPhoneNumber: cellPhoneNumber, userName: userName)
    }

    var isCacheableInMemoryRequest: Bool {
        let nonCache = new == true 
        || name?.isEmpty == false
        || threadIds?.isEmpty == false
        || archived == true
        || creatorCoreUserId != nil
        || partnerCoreUserId != nil
        || partnerCoreContactId != nil
        || metadataCriteria != nil
        || isGroup != nil
        || userName != nil
        || cellPhoneNumber != nil
        return !nonCache
    }
}

extension ThreadsRequest: @retroactive Paginateable{}
