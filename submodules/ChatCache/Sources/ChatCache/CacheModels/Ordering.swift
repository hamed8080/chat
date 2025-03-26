//
// Ordering.swift
// Copyright (c) 2022 ChatCache
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public enum Ordering: String, Identifiable, CaseIterable, Sendable {
    public var id: Self { self }
    case asc
    case desc
}
