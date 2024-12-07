//
//  PersistentManagerProtocol.swift
//  LeitnerBox
//
//  Created by hamed on 2/24/23.
//

import Foundation
import CoreData

public protocol PersistentManagerProtocol {
    var logger: CacheLogDelegate? { get set }
    var baseModelFileName: String { get }
    var container: NSPersistentContainer? { get set }
    var inMemory: Bool { get }
    init(logger: CacheLogDelegate?)
    func viewContext(name: String) -> CacheManagedContext?
    func newBgTask(name: String) -> CacheManagedContext?
    func switchToContainer(userId: Int, completion: @escaping () -> Void)
    func delete()
}
