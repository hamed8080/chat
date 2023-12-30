//
// ChatResponse.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

protocol ChatResponseProtocol {}

protocol ChatResponseWithPaginationProtocol: ChatResponseProtocol {}

public struct ChatResponse<T> {
    public var uniqueId: String?
    public var result: T?
    public var error: ChatError?
    public var contentCount: Int?
    public var pagination: Pagination?
    public var subjectId: Int?
    public var time: Int?
    public var typeCode: String?

    public init(uniqueId: String? = nil, result: T? = nil, error: ChatError? = nil, contentCount: Int? = nil, pagination: Pagination? = nil, subjectId: Int? = nil, time: Int? = nil, typeCode: String?) {
        self.uniqueId = uniqueId
        self.result = result
        self.error = error
        self.contentCount = contentCount
        self.pagination = pagination
        self.subjectId = subjectId
        self.time = time
        self.typeCode = typeCode
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

    public init(hasNext: Bool = false, count: Int = 50, offset: Int = 0, totalCount: Int? = 0) {
        var calculatedHasNext = false
        if let totalCount = totalCount {
            calculatedHasNext = totalCount > (count + offset)
        } else {
            calculatedHasNext = hasNext
        }
        self.totalCount = totalCount ?? 0
        nextOffset = offset + count > self.totalCount ? nil : offset + count
        super.init(hasNext: calculatedHasNext, count: count, offset: offset)
    }
}
