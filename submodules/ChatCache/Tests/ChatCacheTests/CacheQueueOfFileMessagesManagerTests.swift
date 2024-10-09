import XCTest
import ChatModels
import CoreData
import Combine
@testable import ChatCache

@available(iOS 13.0, *)
final class CacheQueueOfFileMessagesManagerTests: XCTestCase, CacheLogDelegate {

    private var sut: CacheQueueOfFileMessagesManager!
    private var cache: CacheManager!
    private var logExpectation = XCTestExpectation(description: "Expected to call log delegate")
    private var notification: MockObjectContextNotificaiton!
    private var objectId: NSManagedObjectID?
    private var cancelables = Set<AnyCancellable>()

    override func setUp() async throws {
        cache = CacheManager(persistentManager: PersistentManager(logger: self))
        _ = await cache.switchToContainer(userId: 1)
        sut = cache.fileQueue
        notification = MockObjectContextNotificaiton(context: sut.viewContext)
    }

    func test_whenInsertAFileQueue_isInStore() {
        // Given
        sut.insert(models: [mockModel()])

        // When
        let exp = expectation(description: "Expected to insert edit queue in to the store.")
        notification.onInsert { (entities: [CDQueueOfFileMessages]) in
            if entities.count > 0 {
                exp.fulfill()
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_whenDuplicateInsertFileQueueWithUnqiueId_existOnlyOneItemInSotre() {
        // Given
        sut.insert(models: [mockModel(textMessage: "TEST", uniqueId: "UNIQUE")])

        // When
        let exp = expectation(description: "Expected to find only one item in the store with same uniqueId.")

        notification.onInsert { (entities: [CDQueueOfFileMessages]) in
            self.sut.insert(models: [self.mockModel(textMessage: "TEST Updated", uniqueId: "UNIQUE")])
        }

        notification.onUpdateIds { (entities: [NSManagedObjectID]) in
            let req = CDQueueOfFileMessages.fetchRequest()
            req.predicate = NSPredicate(format: "%K == %@", #keyPath(CDQueueOfFileMessages.uniqueId) ,"UNIQUE")
            let result = try? self.sut.viewContext.fetch(req)
            if result?.count == 1, result?.first?.textMessage == "TEST Updated" {
                exp.fulfill()
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_whenDeleteFileQueueWithUnqiueId_itDeleteOnlyOneItem() {
        // Given
        sut.insert(models: [mockModel(textMessage: "TEST1", uniqueId: "UNIQUE1")])
        sut.insert(models: [mockModel(textMessage: "TEST2", uniqueId: "UNIQUE2")])

        // When
        let exp = expectation(description: "Expected to delete only one item in the store with same uniqueId.")
        notification.onInsert { (entities: [CDQueueOfFileMessages]) in
            self.sut.delete(["UNIQUE1"])
        }

        notification.onDeletedIds { (objectIds: [NSManagedObjectID]) in
            let req1 = CDQueueOfFileMessages.fetchRequest()
            req1.predicate = NSPredicate(format: "%K == %@", #keyPath(CDQueueOfFileMessages.uniqueId) ,"UNIQUE1")

            let req2 = CDQueueOfFileMessages.fetchRequest()
            req2.predicate = NSPredicate(format: "%K == %@", #keyPath(CDQueueOfFileMessages.uniqueId) ,"UNIQUE2")

            let obj1 = try? self.sut.viewContext.fetch(req1).first
            let obj2 = try? self.sut.viewContext.fetch(req2).first
            if obj1 == nil, obj2 != nil {
                exp.fulfill()
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_whenFetchThreadUnreadFileQueueWithUnqiueId_itDeleteOnlyOneItem() {
        // Given
        sut.insert(models: [mockModel(textMessage: "TEST1", uniqueId: "UNIQUE1"), mockModel(textMessage: "TEST2", uniqueId: "UNIQUE2")])
        sut.insert(models: [mockModel(textMessage: "TEST1", threadId: 2, uniqueId: "UNIQUE3"), mockModel(textMessage: "TEST2", threadId: 2, uniqueId: "UNIQUE4")])

        // When
        let exp = expectation(description: "Expected to fetch two items for a specific threadId.")
        exp.expectedFulfillmentCount = 2
        notification.onInsert { (entities: [CDQueueOfFileMessages]) in
            self.sut.unsendForThread(1, 10, 0) { entities, totalCount in
                if totalCount == 2, entities.count == 2 {
                    exp.fulfill()
                }
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_whenCodableFileQueue_requiredFieldsAreNotNil() {
        // Given
        sut.insert(models: [mockModel(textMessage: "TEST", uniqueId: "UNIQUE")])

        // When
        let exp = expectation(description: "Expected to fillables to be not nil.")
        notification.onInsert { (entities: [CDQueueOfFileMessages]) in
            self.sut.unsendForThread(1, 10, 0) { entities, totalCount in
                let codable = entities.first?.codable
                if codable?.fileName != nil, codable?.messageType != nil {
                    exp.fulfill()
                }
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    private func mockModel(
        fileExtension: String? = ".pdf",
        fileName: String? = "test-cv",
        isPublic: Bool? = false,
        messageId: Int? = 1,
        messageType: MessageType? = .text,
        metadata: String? = nil,
        mimeType: String? = "application/pdf",
        originalName: String? = "",
        repliedTo: Int? = nil,
        systemMetadata: String? = nil,
        textMessage: String? = "TEXT",
        threadId: Int? = 1,
        typeCode: String? = "default",
        uniqueId: String? = UUID().uuidString,
        userGroupHash: String? = "XMXMXMXXM",
        hC: Int? = 640,
        wC: Int? = 480,
        xC: Int? = 0,
        yC: Int? = 0,
        fileToSend: Data? = nil,
        imageToSend: Data? = nil
    ) -> QueueOfFileMessages {

        QueueOfFileMessages(fileExtension: fileExtension,
                            fileName: fileName,
                            isPublic: isPublic,
                            messageType: messageType,
                            metadata: metadata,
                            mimeType: mimeType,
                            originalName: originalName,
                            repliedTo: repliedTo,
                            textMessage: textMessage,
                            threadId: threadId,
                            typeCode: typeCode,
                            uniqueId: uniqueId,
                            userGroupHash: userGroupHash,
                            hC: hC,
                            wC: wC,
                            xC: xC,
                            yC: yC,
                            fileToSend: fileToSend,
                            imageToSend: imageToSend)
    }

    func log(message: String, persist: Bool, error: Error?) {

    }
}
