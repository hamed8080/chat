//
// NSManagedObjectContext+.swift
// Copyright (c) 2022 Additive
//
// Created by Hamed Hosseini on 9/27/22.

import CoreData
public extension NSManagedObjectContext {
    func perform(_ block: @escaping () throws -> Void, errorCompeletion: ((Error) -> Void)? = nil) {
        perform {
            do {
                try block()
            } catch {
                errorCompeletion?(error)
            }
        }
    }
}
