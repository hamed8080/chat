//
// SendableNSPredicate.swift
// Copyright (c) 2022 ChatCache
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct SendableNSPredicate: @unchecked Sendable {
    public let predicate: NSPredicate
    
    public init(predicate: NSPredicate) {
        self.predicate = predicate
    }
}
