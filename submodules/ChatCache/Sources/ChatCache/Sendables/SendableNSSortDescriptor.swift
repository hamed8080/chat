//
// SendableNSSortDescriptor.swift
// Copyright (c) 2022 ChatCache
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct SendableNSSortDescriptor: @unchecked Sendable {
    public let sort: NSSortDescriptor
    
    public init(sort: NSSortDescriptor) {
        self.sort = sort
    }
}
