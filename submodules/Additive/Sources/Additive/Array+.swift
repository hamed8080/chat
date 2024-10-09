//
// Array+.swift
// Copyright (c) 2022 Additive
//
// Created by Hamed Hosseini on 11/2/22

import Foundation

public extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
