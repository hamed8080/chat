//
// ChatResponse.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

protocol ChatResponseProtocol {}

protocol ChatResponseWithPaginationProtocol: ChatResponseProtocol {}

public struct ChatResponse<T> {
    public var uniqueId: String?
    public var result: T?
    public var error: ChatError?
    public var contentCount: Int?
    public var pagination: Pagination?

    public init(uniqueId: String? = nil, result: T? = nil, error: ChatError? = nil, contentCount: Int? = nil, pagination: Pagination? = nil) {
        self.uniqueId = uniqueId
        self.result = result
        self.error = error
        self.contentCount = contentCount
        self.pagination = pagination
    }
}

public class Pagination {
    public var hasNext: Bool
    public var count: Int
    public var offset: Int

    public init(hasNext: Bool, count: Int = 50, offset: Int = 0) {
        self.hasNext = hasNext
        self.count = count
        self.offset = offset
    }
}

public class PaginationWithContentCount: Pagination {
    public var totalCount: Int
    public var nextOffset: Int?

    public init(count: Int = 50, offset: Int = 0, totalCount: Int? = 0) {
        let hasNext = (totalCount ?? 0) > (count + offset)
        self.totalCount = totalCount ?? 0
        nextOffset = offset + count > self.totalCount ? nil : offset + count
        super.init(hasNext: hasNext, count: count, offset: offset)
    }
}
