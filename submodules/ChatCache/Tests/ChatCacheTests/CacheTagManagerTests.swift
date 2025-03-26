import XCTest
import ChatModels
import CoreData
import Combine
@testable import ChatCache

@available(iOS 13.0, *)
final class CacheTagManagerTests: XCTestCase, CacheLogDelegate {

    private var sut: CacheTagManager!
    private var cache: CacheManager!
    private var logExpectation = XCTestExpectation(description: "Expected to call log delegate")
    private var notification: MockObjectContextNotificaiton!
    private var objectId: NSManagedObjectID?
    private var cancelables = Set<AnyCancellable>()

    override func setUp() async throws {
        cache = CacheManager(persistentManager: PersistentManager(logger: self))
        _ = await cache.switchToContainer(userId: 1)
        sut = cache.tag
        notification = MockObjectContextNotificaiton(context: sut.viewContext)
    }

    func test_whenInsertATag_tagIsInStore() {
        // Given
        let tag = Tag(id: 1, name: "Social", active: true)
        sut.insert(models: [tag])

        // When
        let exp = expectation(description: "Expected to insert a tag in to the store.")
        notification.onInsert { (entities: [CDTag]) in
            if entities.first?.id == 1 {
                exp.fulfill()
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_whenDeleteATag_aTagIsDeleted() {
        // Given
        let tag = Tag(id: 1, name: "Social", active: true)
        sut.insert(models: [tag])

        // When
        let exp = expectation(description: "Expected to insert a tag in to the store.")
        notification.onInsert { (entities: [CDTag]) in
            self.sut.delete(1)
        }

        notification.onDeletedIds { (objectIds: [NSManagedObjectID]) in
            self.sut.getTags { tags in
                if tags.count == 0 {
                    exp.fulfill()
                }
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_whenGetTags_itReturnTags() {
        // Given
        let tag1 = Tag(id: 1, name: "Social", active: true)
        let tag2 = Tag(id: 2, name: "Media", active: true)
        sut.insert(models: [tag1, tag2])

        // When
        let exp = expectation(description: "Expected to insert a tag in to the store.")
        notification.onInsert { (entities: [CDTag]) in
            self.sut.getTags { tags in
                if tags.count == 2 {
                    exp.fulfill()
                }
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_whenCodableTagParticipants_shoulNotbeNil() {
        // Given
        let tagParticipants: [TagParticipant] = [.init(id: 1, active: false, tagId: 1, threadId: 1, conversation: Conversation(id: 1))]
        let tag = Tag(id: 1, name: "Social", active: true, tagParticipants: tagParticipants)
        sut.insert(models: [tag])

        // When
        let exp = expectation(description: "Expected to decoded tagParticipants.")
        notification.onInsert { (entities: [CDTag]) in
            self.sut.getTags { tags in
                if tags.map({$0.codable}).first?.tagParticipants?.count == 1 {
                    exp.fulfill()
                }
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_whenActiveAndNameIsNil_fillThemWithDefaultValues() {
        // Given
        let _ = CDTag.insertEntity(sut.viewContext)
        sut.viewContext.perform {
            self.sut.saveViewContext()
        }

        // When
        let exp = expectation(description: "Expected to get default value whenever name and active is nil.")
        notification.onInsert { (entities: [CDTag]) in
            self.sut.getTags { tags in
                if let tag = tags.map({$0.codable}).first, tag.name == "", tag.active == false, tag.id == 0 {
                    exp.fulfill()
                }
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func log(message: String, persist: Bool, error: Error?) {

    }
}
