//
//  File.swift
//  
//
//  Created by hamed on 6/5/23.
//

import Foundation
import CoreData
@testable import ChatCache

final class MockPersistentManager: PersistentManagerProtocol {
    var logger: ChatCache.CacheLogDelegate?
    var baseModelFileName: String = ""
    var container: NSPersistentContainer?
    var inMemory: Bool = false
    var mockContext: NSManagedObjectContextProtocol?

    init(logger: ChatCache.CacheLogDelegate?) {
        self.logger = logger
    }

    func viewContext(name: String) -> NSManagedObjectContextProtocol? {
        return mockContext
    }

    func newBgTask(name: String) -> NSManagedObjectContextProtocol? {
        return mockContext
    }

    func switchToContainer(userId: Int, completion: () -> Void) {
        completion()
    }

    func delete() {

    }
}
