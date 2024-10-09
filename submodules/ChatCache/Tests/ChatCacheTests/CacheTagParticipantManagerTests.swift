import XCTest
import ChatModels
import CoreData
import Combine
@testable import ChatCache

@available(iOS 13.0, *)
final class CacheTagParticipantManagerTests: XCTestCase, CacheLogDelegate {

    private var sut: CacheTagParticipantManager!
    private var cache: CacheManager!
    private var logExpectation = XCTestExpectation(description: "Expected to call log delegate")
    private var notification: MockObjectContextNotificaiton!
    private var objectId: NSManagedObjectID?
    private var cancelables = Set<AnyCancellable>()

    override func setUp() async throws {
        cache = CacheManager(persistentManager: PersistentManager(logger: self))
        _ = await cache.switchToContainer(userId: 1)
        sut = cache.tagParticipant
        notification = MockObjectContextNotificaiton(context: sut.viewContext)
    }

    func test_whenInsertATagParticipant_tagIsInStore() {
        // Given

        let thread = Conversation(id: 1)
        let participant = TagParticipant(id: 1, active: true, tagId: 1, threadId: 1, conversation: thread)

        // When
        sut.insert(models: [participant])
        let exp = expectation(description: "Expected to insert a tag participant in to the store.")
        notification.onInsert { (entities: [CDTagParticipant]) in
            if let participant = entities.first, participant.id == 1, participant.tagId == 1 {
                exp.fulfill()
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_whenInsertATagWithParticipants_tagParticipantsAreInTheStore() {
        // Given
        let thread = Conversation(id: 1)
        let participant1 = TagParticipant(id: 1, active: true, tagId: 1, threadId: 1, conversation: thread)
        let participant2 = TagParticipant(id: 2, active: true, tagId: 1, threadId: 1, conversation: thread)
        let tag = Tag(id: 1, name: "Social", active: true, tagParticipants: [participant1, participant2])

        // When
        cache.tag?.insert(models: [tag])
        let exp = expectation(description: "Expected to insert a tag with participants in to the store.")
        notification.onInsert { (entities: [CDTag]) in
            let req = CDTagParticipant.fetchRequest()
            req.predicate = NSPredicate(format: "tagId == %i", 1)
            let participnts = try? self.sut.viewContext.fetch(req)
            if participnts?.count == 2 {
                exp.fulfill()
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_whenDeleteATag_allTagParticipantsForThatTagDeleted() {
        // Given
        let thread = Conversation(id: 1)
        let participant1 = TagParticipant(id: 1, active: true, tagId: 1, threadId: 1, conversation: thread)
        let participant2 = TagParticipant(id: 2, active: true, tagId: 1, threadId: 1, conversation: thread)
        let tag = Tag(id: 1, name: "Social", active: true, tagParticipants: [participant1, participant2])

        // When
        cache.tag?.insert(models: [tag])
        let exp = expectation(description: "Expected to delete all the tagParticipnts related to the tag with participants in to the store.")
        notification.onInsert { (entities: [CDTag]) in
            self.cache.tag?.delete(1)
        }

        notification.onDeletedIds { ids in
            let req = CDTagParticipant.fetchRequest()
            req.predicate = NSPredicate(format: "tagId == %i", 1)
            let tags = try? self.sut.viewContext.fetch(req)
            if tags?.count == 0 {
                exp.fulfill()
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_whenDeleteAParticipant_anotherParticipantsIsThere() {
        // Given
        let thread = Conversation(id: 1)
        let participant1 = TagParticipant(id: 1, active: true, tagId: 1, threadId: 1, conversation: thread)
        let participant2 = TagParticipant(id: 2, active: true, tagId: 1, threadId: 1, conversation: thread)
        let tag = Tag(id: 1, name: "Social", active: true, tagParticipants: [participant1, participant2])

        // When
        cache.tag?.insert(models: [tag])
        let exp = expectation(description: "Expected to delete a tagParticipnt related a tag in to the store.")
        notification.onInsert { (entities: [CDTag]) in
            self.sut.delete([.init(id: 1)], tagId: 1)
        }

        notification.onDeletedIds { ids in
            let req = CDTagParticipant.fetchRequest()
            req.predicate = NSPredicate(format: "tagId == %i", 1)
            let tags = try? self.sut.viewContext.fetch(req)
            if tags?.count == 1 {
                exp.fulfill()
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func log(message: String, persist: Bool, error: Error?) {

    }
}
