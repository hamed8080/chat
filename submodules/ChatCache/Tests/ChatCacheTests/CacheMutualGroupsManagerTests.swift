import XCTest
import ChatModels
import CoreData
import Combine
@testable import ChatCache

@available(iOS 13.0, *)
final class CacheMutualGroupsManagerTests: XCTestCase, CacheLogDelegate {

    private var sut: CacheMutualGroupManager!
    private var cache: CacheManager!
    private var logExpectation = XCTestExpectation(description: "Expected to call log delegate")
    private var notification: MockObjectContextNotificaiton!
    private var objectId: NSManagedObjectID?
    private var cancelables = Set<AnyCancellable>()

    override func setUp() async throws {
        cache = CacheManager(persistentManager: PersistentManager(logger: self))
        _ = await cache.switchToContainer(userId: 1)
        sut = cache.mutualGroup
        notification = MockObjectContextNotificaiton(context: sut.viewContext)
    }

    func test_whenInsertAMutualGroup_isInStore() {
        // Given
        let threads: [Conversation] = [.init(id: 1), .init(id: 2)]
        sut.insert(threads, idType: .contactId, mutualId: "1")

        // When
        let exp = expectation(description: "Expected to insert a mutual group item in to the store.")
        notification.onInsert { (entities: [CDMutualGroup]) in
            if entities.first?.conversations?.count == 2 {
                exp.fulfill()
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_whenGetMutualGroups_itReturnMutualsOnlyForAParticularInviteeId() {
        // Given
        let mutualThreads1: [Conversation] = [.init(id: 1), .init(id: 2)]
        let mutualThreads2: [Conversation] = [.init(id: 1), .init(id: 2), .init(id: 3)]
        sut.insert(mutualThreads1, idType: .contactId, mutualId: "1")
        sut.insert(mutualThreads2, idType: .username, mutualId: "j.john")

        // When
        let exp = expectation(description: "Expected to get mutual groups for a contact Id 1.")
        exp.expectedFulfillmentCount = 2
        notification.onInsert { (entities: [CDMutualGroup]) in
            self.sut.mutualGroups("1") { mutualGroups in
                if mutualGroups.first?.conversations?.count == 2 {
                    exp.fulfill()
                }
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_whenCodableMutualGroup_allFilledsAreFill() {
        // Given
        let threads: [Conversation] = [.init(id: 1), .init(id: 2)]
        sut.insert(threads, idType: .contactId, mutualId: "1")

        // When
        let exp = expectation(description: "Expected to fillables to be not nil.")
        notification.onInsert { (entities: [CDMutualGroup]) in
            let first = entities.first?.codable
            if first?.conversations != nil, first?.idType != nil, first?.mutualId != nil {
                exp.fulfill()
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    private func mockModel(
        idType: InviteeTypes = .contactId,
        mutualId: String? = "1",
        conversations: [Conversation] = [] ) -> MutualGroup {
        return MutualGroup(idType: idType,
                           mutualId: mutualId,
                           conversations: conversations)
    }


    func log(message: String, persist: Bool, error: Error?) {

    }
}
