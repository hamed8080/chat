//
// Ordering.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/2/22

import Foundation

public enum Ordering: String, Identifiable, CaseIterable {
    public var id: Self { self }
    case asc
    case desc
}
