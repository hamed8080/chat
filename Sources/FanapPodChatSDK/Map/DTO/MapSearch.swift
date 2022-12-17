//
// MapSearch.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/2/22

import Foundation

open class MapSearch {
    public var count: Int
    public var items: [MapItem]?

    public init(count: Int, items: [MapItem]) {
        self.count = count
        self.items = items
    }
}
