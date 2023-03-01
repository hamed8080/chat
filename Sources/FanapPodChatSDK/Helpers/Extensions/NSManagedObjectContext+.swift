//
//  NSManagedObjectContext+.swift
//  FanapPodChatSDK
//
//  Created by hamed on 3/1/23.
//

import CoreData
extension NSManagedObjectContext {
    func perform(_ block: @escaping () throws -> Void) {
        perform {
            do {
                try block()
            } catch {
                ChatManager.activeInstance?.logger?.log(message: error.localizedDescription)
            }
        }
    }
}
