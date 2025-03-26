//
// DefaultMockCacheManager.swift
// Copyright (c) 2022 LeitnerBox
//
// Created by Hamed Hosseini on 10/28/22.

import Foundation
@testable import ChatCache

@available(iOS 13.0, *)
class DefaultMockCacheManager: CacheLogDelegate {
    var context: MockNSManagedObjectContext?
    var cache: CacheManager?
    var notification: MockObjectContextNotificaiton?

    init() {
        let mockContainer = MockPersistentManager(logger: self)
        let mockContext = MockNSManagedObjectContext()
        mockContainer.mockContext = mockContext
        context = mockContext
        cache = CacheManager(persistentManager: mockContainer)
        cache?.switchToContainer(userId: 1)
        notification = MockObjectContextNotificaiton(context: context!)
    }

    func log(message: String, persist: Bool, error: Error?) {

    }
}
