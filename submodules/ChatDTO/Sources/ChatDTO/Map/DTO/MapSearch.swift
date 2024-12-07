//
// MapSearch.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct MapSearch: Sendable {
    public var count: Int
    public var items: [MapItem]?

    public init(count: Int, items: [MapItem]) {
        self.count = count
        self.items = items
    }
}
