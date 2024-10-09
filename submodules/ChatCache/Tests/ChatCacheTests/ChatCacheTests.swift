import XCTest
import ChatModels
import CoreData
import Combine
@testable import ChatCache

@available(iOS 13.0, *)
final class CacheManagerTests: XCTestCase, CacheLogDelegate {
    var sut: CacheManager!
    var logExpectation = XCTestExpectation(description: "Expected to call log delegate")
    var notification: NotificationCenter!
    var cancelable = Set<AnyCancellable>()

    override func setUpWithError() throws {
        sut = CacheManager(persistentManager: PersistentManager(logger: self))
        notification = NotificationCenter.default
        sut.switchToContainer(userId: 1)
    }

    func test_initWithInMemory() {
        XCTAssertTrue(self.sut.persistentManager.inMemory, "Expected to init an In Memory SQLite")
        XCTAssertEqual(self.sut.persistentManager.container?.persistentStoreDescriptions.first?.url?.absoluteString, "file:///dev/null", "Expected the file path of Sqlite to be in memory address.")
    }
    
    func testManagers_whenLoadPersistentManager_initAllManagers() {
        // When
        sut.switchToContainer(userId: 1) {
            // Then
            XCTAssertNotNil(self.sut.assistant, "Expected the assistant to be not nil, but it is nil.")
            XCTAssertNotNil(self.sut.contact, "Expected the contact to be not nil, but it is nil.")
            XCTAssertNotNil(self.sut.conversation, "Expected the conversation to be not nil, but it is nil.")
            XCTAssertNotNil(self.sut.file, "Expected the file to be not nil, but it is nil.")
            XCTAssertNotNil(self.sut.image, "Expected the image to be not nil, but it is nil.")
            XCTAssertNotNil(self.sut.message, "Expected the message to be not nil, but it is nil.")
            XCTAssertNotNil(self.sut.mutualGroup, "Expected the mutualGroup to be not nil, but it is nil.")
            XCTAssertNotNil(self.sut.participant, "Expected the participant to be not nil, but it is nil.")
            XCTAssertNotNil(self.sut.editQueue, "Expected the editQueue to be not nil, but it is nil.")
            XCTAssertNotNil(self.sut.textQueue, "Expected the textQueue to be not nil, but it is nil.")
            XCTAssertNotNil(self.sut.forwardQueue, "Expected the forwardQueue to be not nil, but it is nil.")
            XCTAssertNotNil(self.sut.fileQueue, "Expected the fileQueue to be not nil, but it is nil.")
            XCTAssertNotNil(self.sut.tag, "Expected the tag to be not nil, but it is nil.")
            XCTAssertNotNil(self.sut.tagParticipant, "Expected the tagParticipant to be not nil, but it is nil.")
            XCTAssertNotNil(self.sut.user, "Expected the user to be not nil, but it is nil.")
            XCTAssertNotNil(self.sut.userRole, "Expected the userRole to be not nil, but it is nil.")

        }
    }

    func testDeleteTextQueue_whenDeleteCalled_cacheIsDeleted() {
        // Given
        let uniqueId = UUID().uuidString
        let messageQueue = QueueOfTextMessages(messageType: .text, textMessage: "Hello", threadId: 123, uniqueId: uniqueId)
        sut.textQueue?.insert(models: [messageQueue])
        let context = sut.persistentManager.viewContext(name: "Main")
        // When
        let exp = expectation(description: "Expected the message queue object has been deleted.")
        Publishers.Merge(
            notification.publisher(for: .NSManagedObjectContextObjectsDidChange, object: context),
            notification.publisher(for: .NSManagedObjectContextDidMergeChangesObjectIDs, object: context)
        ).sink { notification in
            if notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject> != nil {
                self.sut.deleteQueues(uniqueIds: [uniqueId])
            } else if notification.userInfo?[NSDeletedObjectIDsKey] as? Set<NSManagedObjectID> != nil {
                exp.fulfill()
            }
        }
        .store(in: &cancelable)

        // Then
        wait(for: [exp], timeout: 1)
    }

    func testDeleteEditQueue_whenDeleteCalled_cacheIsDeleted() {
        // Given
        let uniqueId = UUID().uuidString
        let messageQueue = QueueOfEditMessages(messageType: .text, textMessage: "Hello", threadId: 123, uniqueId: uniqueId)
        sut.editQueue?.insert(models: [messageQueue])
        let context = sut.persistentManager.viewContext(name: "Main")
        // When
        let exp = expectation(description: "Expected the edit message queue object has been deleted.")
        Publishers.Merge(
            notification.publisher(for: .NSManagedObjectContextObjectsDidChange, object: context),
            notification.publisher(for: .NSManagedObjectContextDidMergeChangesObjectIDs, object: context)
        ).sink { notification in
            if notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject> != nil {
                self.sut.deleteQueues(uniqueIds: [uniqueId])
            } else if notification.userInfo?[NSDeletedObjectIDsKey] as? Set<NSManagedObjectID> != nil {
                exp.fulfill()
            }
        }
        .store(in: &cancelable)

        // Then
        wait(for: [exp], timeout: 1)
    }

    func testDeleteFileQueue_whenDeleteCalled_cacheIsDeleted() {
        // Given
        let uniqueId = UUID().uuidString
        let messageQueue = QueueOfFileMessages(messageType: .text, textMessage: "Hello", threadId: 123, uniqueId: uniqueId)
        sut.fileQueue?.insert(models: [messageQueue])
        let context = sut.persistentManager.viewContext(name: "Main")
        // When
        let exp = expectation(description: "Expected the file message queue object has been deleted.")
        Publishers.Merge(
            notification.publisher(for: .NSManagedObjectContextObjectsDidChange, object: context),
            notification.publisher(for: .NSManagedObjectContextDidMergeChangesObjectIDs, object: context)
        ).sink { notification in
            if notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject> != nil {
                self.sut.deleteQueues(uniqueIds: [uniqueId])
            } else if notification.userInfo?[NSDeletedObjectIDsKey] as? Set<NSManagedObjectID> != nil {
                exp.fulfill()
            }
        }
        .store(in: &cancelable)

        // Then
        wait(for: [exp], timeout: 1)
    }

    func testDeleteForwardQueue_whenDeleteCalled_cacheIsDeleted() {
        // Given
        let uniqueIds = [UUID().uuidString, UUID().uuidString, UUID().uuidString]
        let messageQueue = QueueOfForwardMessages(fromThreadId: 123, messageIds: [123,1234,12345], threadId: 1111, uniqueIds: uniqueIds)
        sut.forwardQueue?.insert(models: [messageQueue])
        let context = sut.persistentManager.viewContext(name: "Main")
        // When
        let exp = expectation(description: "Expected the forward messages queue objects has been deleted.")
        Publishers.Merge(
            notification.publisher(for: .NSManagedObjectContextObjectsDidChange, object: context),
            notification.publisher(for: .NSManagedObjectContextDidMergeChangesObjectIDs, object: context)
        ).sink { [self] notification in
            if notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject> != nil {
                self.sut.deleteQueues(uniqueIds: uniqueIds)
            } else if notification.userInfo?[NSDeletedObjectIDsKey] as? Set<NSManagedObjectID> != nil {
                exp.fulfill()
            }
        }
        .store(in: &cancelable)

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_delete_(){
        sut.delete()
        XCTAssertNil(sut.persistentManager.container?.persistentStoreCoordinator.persistentStores.first, "Expected the store gets nil")
    }

    func log(message: String, persist: Bool, error: Error?) {
        logExpectation.fulfill()
    }

    override func tearDownWithError() throws {
        notification.removeObserver(self, name: .NSManagedObjectContextObjectsDidChange, object: sut.persistentManager.viewContext(name: "Main"))
    }
}
