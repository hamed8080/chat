//
// ContactsRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22


import Foundation
import ChatDTO
import ChatCore
import ChatCache

extension ContactsRequest: @retroactive ChatSendable {}

public extension ContactsRequest {    
    var content: String? { jsonString }
    var chatTypeCodeIndex: Index { typeCodeIndex }
}

public extension ContactsRequest {
    var fetchRequest: FetchContactsRequest {
        .init(id: id,
              count: size,
              cellphoneNumber: cellphoneNumber,
              email: email,
              coreUserId: coreUserId,
              offset: offset,
              order: fetchOrdering,
              query: q,
              summery: summery)
    }

    fileprivate var fetchOrdering: Ordering {
        guard let order = order, let order = Ordering(rawValue: order) else { return .asc }
        return order
    }
}

extension ContactsRequest: @retroactive Paginateable {
    public var count: Int { size }
}
