
import Foundation
import CoreData
import ChatCache
import Combine

@available(iOS 13.0, *)
final class MockObjectContextNotificaiton {
    var cancelable = Set<AnyCancellable>()
    var notification: NotificationCenter
    var context: NSManagedObjectContextProtocol

    init(context: NSManagedObjectContextProtocol, cancelable: Set<AnyCancellable> = Set<AnyCancellable>(), notification: NotificationCenter = .default) {
        self.cancelable = cancelable
        self.notification = notification
        self.context = context
    }

    func onUpdate<Entity: EntityProtocol>(completion: @escaping ([Entity]) -> Void ) {
        notification
            .publisher(for: .NSManagedObjectContextObjectsDidChange, object: context)
            .sink { notification in
                if let updatedObject = (notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject>)?.filter({ $0 is Entity }) {
                    completion(updatedObject.compactMap{ $0 as? Entity })
                }
            }
            .store(in: &cancelable)
    }

    func onUpdateIds(completion: @escaping ([NSManagedObjectID]) -> Void ) {
        notification
            .publisher(for: .NSManagedObjectContextDidMergeChangesObjectIDs, object: context)
            .sink { notification in
                if let updatedObjectIds = notification.userInfo?[NSUpdatedObjectIDsKey] as? Set<NSManagedObjectID> {
                    completion(Array(updatedObjectIds))
                }
            }
            .store(in: &cancelable)
    }

    func onInsert<Entity: EntityProtocol>(onCompeletion: @escaping ([Entity]) -> Void ) {
        notification
            .publisher(for: .NSManagedObjectContextObjectsDidChange, object: context)
            .sink { notification in
                if let insertedObjects = (notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject>)?.filter({ $0 is Entity }) {
                    onCompeletion(insertedObjects.compactMap{ $0 as? Entity })
                }
            }
            .store(in: &cancelable)
    }

    func onInsertedIds(completion: @escaping ([NSManagedObjectID]) -> Void ) {
        notification
            .publisher(for: .NSManagedObjectContextDidMergeChangesObjectIDs, object: context)
            .sink { notification in
                if let insertedObjectIds = notification.userInfo?[NSInsertedObjectIDsKey] as? Set<NSManagedObjectID> {
                    completion(Array(insertedObjectIds))
                }
            }
            .store(in: &cancelable)
    }


    func onDelete<Entity: EntityProtocol>(onCompeletion: @escaping ([Entity]) -> Void ) {
        notification.publisher(for: .NSManagedObjectContextObjectsDidChange, object: context)
            .sink { notification in
                if let deletedObjects = (notification.userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject>)?.filter({ $0 is Entity }) {
                    onCompeletion(deletedObjects.compactMap{ $0 as? Entity })
                }
            }
            .store(in: &cancelable)
    }

    func onDeletedIds(onCompeletion: @escaping ([NSManagedObjectID]) -> Void ) {
        notification.publisher(for: .NSManagedObjectContextDidMergeChangesObjectIDs, object: context)
            .sink { notification in
                if let deletedObjectIds = (notification.userInfo?[NSDeletedObjectIDsKey] as? Set<NSManagedObjectID>) {
                    onCompeletion(Array(deletedObjectIds))
                }
            }
            .store(in: &cancelable)
    }
}
