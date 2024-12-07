//
// SendableNSManagedObjectContext.swift
// Copyright (c) 2022 Logger
//
// Created by Hamed Hosseini on 12/14/22

import CoreData

public struct SendableNSManagedObjectContext: @unchecked Sendable {
    public let context: NSManagedObjectContext
    
    public init(context: NSManagedObjectContext) {
        self.context = context
    }
}

public extension NSManagedObjectContext {
    var sendable: SendableNSManagedObjectContext {
        return SendableNSManagedObjectContext(context: self)
    }
}
