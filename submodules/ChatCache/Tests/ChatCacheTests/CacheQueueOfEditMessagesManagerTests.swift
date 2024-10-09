import XCTest
import ChatModels
import CoreData
import Combine
@testable import ChatCache

@available(iOS 13.0, *)
final class CacheQueueOfEditMessagesManagerTests: XCTestCase, CacheLogDelegate {

    private var sut: CacheQueueOfEditMessagesManager!
    private var cache: CacheManager!
    private var logExpectation = XCTestExpectation(description: "Expected to call log delegate")
    private var notification: MockObjectContextNotificaiton!
    private var objectId: NSManagedObjectID?
    private var cancelables = Set<AnyCancellable>()

    override func setUp() async throws {
        cache = CacheManager(persistentManager: PersistentManager(logger: self))
        _ = await cache.switchToContainer(userId: 1)
        sut = cache.editQueue
        notification = MockObjectContextNotificaiton(context: sut.viewContext)
    }

    func test_whenInsertAEditQueue_isInStore() {
        // Given
        sut.insert(models: [mockModel()])

        // When
        let exp = expectation(description: "Expected to insert edit queue in to the store.")
        notification.onInsert { (entities: [CDQueueOfEditMessages]) in
            if entities.count > 0 {
                exp.fulfill()
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_whenDuplicateInsertEditQueueWithUnqiueId_existOnlyOneItemInSotre() {
        // Given
        sut.insert(models: [mockModel(textMessage: "TEST", uniqueId: "UNIQUE")])

        // When
        let exp = expectation(description: "Expected to find only one item in the store with same uniqueId.")

        notification.onInsert { (entities: [CDQueueOfEditMessages]) in
            self.sut.insert(models: [self.mockModel(textMessage: "TEST Updated", uniqueId: "UNIQUE")])
        }

        notification.onUpdateIds { (entities: [NSManagedObjectID]) in
            let req = CDQueueOfEditMessages.fetchRequest()
            req.predicate = NSPredicate(format: "%K == %@", #keyPath(CDQueueOfEditMessages.uniqueId) ,"UNIQUE")
            let result = try? self.sut.viewContext.fetch(req)
            if result?.count == 1, result?.first?.textMessage == "TEST Updated" {
                exp.fulfill()
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_whenDeleteEditQueueWithUnqiueId_itDeleteOnlyOneItem() {
        // Given
        sut.insert(models: [mockModel(textMessage: "TEST1", uniqueId: "UNIQUE1")])
        sut.insert(models: [mockModel(textMessage: "TEST2", uniqueId: "UNIQUE2")])

        // When
        let exp = expectation(description: "Expected to delete only one item in the store with same uniqueId.")
        notification.onInsert { (entities: [CDQueueOfTextMessages]) in
            self.sut.delete(["UNIQUE1"])
        }

        notification.onDeletedIds { (objectIds: [NSManagedObjectID]) in
            let req1 = CDQueueOfEditMessages.fetchRequest()
            req1.predicate = NSPredicate(format: "%K == %@", #keyPath(CDQueueOfEditMessages.uniqueId) ,"UNIQUE1")

            let req2 = CDQueueOfEditMessages.fetchRequest()
            req2.predicate = NSPredicate(format: "%K == %@", #keyPath(CDQueueOfEditMessages.uniqueId) ,"UNIQUE2")

            let obj1 = try? self.sut.viewContext.fetch(req1).first
            let obj2 = try? self.sut.viewContext.fetch(req2).first
            if obj1 == nil, obj2 != nil {
                exp.fulfill()
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_whenFetchThreadUnreadEditQueueWithUnqiueId_itDeleteOnlyOneItem() {
        // Given
        sut.insert(models: [mockModel(textMessage: "TEST1", uniqueId: "UNIQUE1"), mockModel(textMessage: "TEST2", uniqueId: "UNIQUE2")])
        sut.insert(models: [mockModel(textMessage: "TEST1", threadId: 2, uniqueId: "UNIQUE3"), mockModel(textMessage: "TEST2", threadId: 2, uniqueId: "UNIQUE4")])

        // When
        let exp = expectation(description: "Expected to fetch two items for a specific threadId.")
        exp.expectedFulfillmentCount = 2
        notification.onInsert { (entities: [CDQueueOfEditMessages]) in
            self.sut.unsendForThread(1, 10, 0) { entities, totalCount in
                if totalCount == 2, entities.count == 2 {
                    exp.fulfill()
                }
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_whenCodableEditQueue_requiredFieldsAreNotNil() {
        // Given
        sut.insert(models: [mockModel(textMessage: "TEST", uniqueId: "UNIQUE")])

        // When
        let exp = expectation(description: "Expected to fillables to be not nil.")
        notification.onInsert { (entities: [CDQueueOfEditMessages]) in
            self.sut.unsendForThread(1, 10, 0) { entities, totalCount in
                let codable = entities.first?.codable
                if codable?.textMessage != nil, codable?.messageType != nil {
                    exp.fulfill()
                }
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    private func mockModel(
        messageId: Int? = 1,
        messageType: MessageType? = .text,
        metadata: String? = nil,
        repliedTo: Int? = nil,
        systemMetadata: String? = nil,
        textMessage: String? = "TEXT",
        threadId: Int? = 1,
        typeCode: String? = "default",
        uniqueId: String? = UUID().uuidString
    ) -> QueueOfEditMessages {
        QueueOfEditMessages(messageId: messageId,
                            messageType: messageType,
                            metadata: metadata,
                            repliedTo: repliedTo,
                            textMessage: textMessage,
                            threadId: threadId,
                            typeCode: typeCode,
                            uniqueId: uniqueId)
    }

    func log(message: String, persist: Bool, error: Error?) {

    }
}
