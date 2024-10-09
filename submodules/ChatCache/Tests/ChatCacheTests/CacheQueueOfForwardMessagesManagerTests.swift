import XCTest
import ChatModels
import CoreData
import Combine
@testable import ChatCache

@available(iOS 13.0, *)
final class CacheQueueOfForwardMessagesManagerTests: XCTestCase, CacheLogDelegate {

    private var sut: CacheQueueOfForwardMessagesManager!
    private var cache: CacheManager!
    private var logExpectation = XCTestExpectation(description: "Expected to call log delegate")
    private var notification: MockObjectContextNotificaiton!
    private var objectId: NSManagedObjectID?
    private var cancelables = Set<AnyCancellable>()

    override func setUp() async throws {
        cache = CacheManager(persistentManager: PersistentManager(logger: self))
        _ = await cache.switchToContainer(userId: 1)
        sut = cache.forwardQueue
        notification = MockObjectContextNotificaiton(context: sut.viewContext)
    }

    func test_whenInsertAForwardQueue_isInStore() {
        // Given
        sut.insert(models: [mockModel()])

        // When
        let exp = expectation(description: "Expected to insert forward queue in to the store.")
        notification.onInsert { (entities: [CDQueueOfForwardMessages]) in
            if entities.count > 0 {
                exp.fulfill()
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_whenDuplicateInsertForwardQueueWithUnqiueId_existOnlyOneItemInSotre() {
        // Given
        sut.insert(models: [mockModel()])

        // When
        let exp = expectation(description: "Expected to find only one item in the store with same uniqueId.")

        notification.onInsert { (entities: [CDQueueOfForwardMessages]) in
            self.sut.insert(models: [self.mockModel()])
        }

        notification.onUpdateIds { (entities: [NSManagedObjectID]) in
            let req = CDQueueOfForwardMessages.fetchRequest()
            req.predicate = NSPredicate(format: "%K == %@", #keyPath(CDQueueOfForwardMessages.uniqueIds) ,"UNIQUE1,UNIQUE2")
            let result = try? self.sut.viewContext.fetch(req)
            if result?.count == 1 {
                exp.fulfill()
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_whenDeleteForwardQueueWithUnqiueId_itDeleteOnlyOneItem() {
        // Given
        sut.insert(models: [mockModel(uniqueIds: ["UNIQUE1","UNIQUE2"])])
        sut.insert(models: [mockModel(uniqueIds: ["UNIQUE3"])])

        // When
        let exp = expectation(description: "Expected to delete only one item in the store with same uniqueId.")
        notification.onInsert { (entities: [CDQueueOfForwardMessages]) in
            self.sut.delete(["UNIQUE1", "UNIQUE2"])
        }

        notification.onDeletedIds { (objectIds: [NSManagedObjectID]) in
            let req1 = CDQueueOfForwardMessages.fetchRequest()
            req1.predicate = NSPredicate(format: "%K == %@", #keyPath(CDQueueOfForwardMessages.uniqueIds) ,"UNIQUE1,UNIQUE2")

            let req2 = CDQueueOfForwardMessages.fetchRequest()
            req2.predicate = NSPredicate(format: "%K == %@", #keyPath(CDQueueOfForwardMessages.uniqueIds) ,"UNIQUE3")

            let obj1 = try? self.sut.viewContext.fetch(req1).first
            let obj2 = try? self.sut.viewContext.fetch(req2).first
            if obj1 == nil, obj2 != nil {
                exp.fulfill()
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_whenFetchThreadUnreadForwardQueueWithUnqiueId_itDeleteOnlyOneItem() {
        // Given
        sut.insert(models: [mockModel(uniqueIds: ["UNIQUE1"]), mockModel(uniqueIds: ["UNIQUE2"])])
        sut.insert(models: [mockModel(threadId: 2, uniqueIds: ["UNIQUE3"]), mockModel(threadId: 2, uniqueIds: ["UNIQUE4"])])

        // When
        let exp = expectation(description: "Expected to fetch two items for a specific threadId.")
        exp.expectedFulfillmentCount = 2
        notification.onInsert { (entities: [CDQueueOfForwardMessages]) in
            self.sut.unsendForThread(1, 10, 0) { entities, totalCount in
                if totalCount == 2, entities.count == 2 {
                    exp.fulfill()
                }
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_whenCodableForwardQueue_requiredFieldsAreNotNil() {
        // Given
        sut.insert(models: [mockModel()])

        // When
        let exp = expectation(description: "Expected to fillables to be not nil.")
        notification.onInsert { (entities: [CDQueueOfForwardMessages]) in
            self.sut.unsendForThread(1, 10, 0) { entities, totalCount in
                let codable = entities.first?.codable
                if codable?.fromThreadId != nil, codable?.threadId != nil {
                    exp.fulfill()
                }
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    private func mockModel(
        fromThreadId: Int? = 1,
        messageIds: [Int]? = [1,2,3],
        threadId: Int? = 1,
        typeCode: String? = "default",
        uniqueIds: [String]? = ["UNIQUE1", "UNIQUE2"]
    ) -> QueueOfForwardMessages {
        QueueOfForwardMessages(fromThreadId: fromThreadId,
                               messageIds: messageIds,
                               threadId: threadId,
                               typeCode: typeCode,
                               uniqueIds: uniqueIds)
    }

    func log(message: String, persist: Bool, error: Error?) {

    }
}
