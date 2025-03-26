//
// Paginateable.swift
// Copyright (c) 2022 ChatCore
//
// Created by Hamed Hosseini on 12/16/22

import Foundation

public protocol Paginateable {
    var count: Int { get }
    var offset: Int { get }
    var uniqueId: String { get }
}
