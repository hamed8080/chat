//
// GetHistoryRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatCore
import ChatDTO
import ChatCache

extension GetHistoryRequest: @retroactive ChatSendable, @retroactive SubjectProtocol {}

public extension GetHistoryRequest {
    var subjectId: Int { threadId }
    var content: String? { jsonString }
    var chatTypeCodeIndex: Index { typeCodeIndex }
}

public extension GetHistoryRequest {
    var fetchRequest: FetchMessagesRequest {
        .init(messageType: messageType,
              fromTime: fromTime,
              messageId: messageId,
              uniqueIds: uniqueIds,
              toTime: toTime,
              query: query,
              threadId: threadId,
              offset: nonNegativeOffset,
              count: count,
              order: order,
              hashtag: hashtag,
              toTimeNanos: toTimeNanos)
    }
}

extension GetHistoryRequest: @retroactive Paginateable{}
