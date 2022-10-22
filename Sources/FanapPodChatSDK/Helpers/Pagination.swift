//
// Pagination.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

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
