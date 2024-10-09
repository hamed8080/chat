import XCTest
import ChatModels
import CoreData
import Combine
@testable import ChatCache

@available(iOS 13.0, *)
final class CacheAssistantManagerTests: XCTestCase, CacheLogDelegate {
    var sut: CacheAssistantManager!
    var cache: CacheManager!
    var logExpectation = XCTestExpectation(description: "Expected to call log delegate")
    var notification: MockObjectContextNotificaiton!
    var objectId: NSManagedObjectID?

    override func setUp() async throws {
        cache = CacheManager(persistentManager: PersistentManager(logger: self))
        _ = await cache.switchToContainer(userId: 1)
        sut = cache.assistant
        notification = MockObjectContextNotificaiton(context: sut.viewContext)
    }

    func test_whenInsertAssisatnt_isInStore() {
        // Given
        sut.insert(models: [mockModel()])

        // When
        let exp = expectation(description: "Expected to insert an assistant to store.")
        notification.onInsert { (entities: [CDAssistant]) in
            if entities.count > 0 {
                exp.fulfill()
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_whenDeleteAnAssisatnt_isDeleted() {
        // Given
        let models = [mockModel()]
        sut.insert(models: models)

        // When
        let exp = expectation(description: "Expected to delete an assistant from store.")
        notification.onInsert { (entities: [CDAssistant]) in
            self.sut.delete(models)
        }

        // Then
        notification.onDelete { (entities: [CDAssistant]) in
            if entities.count > 0 {
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 1)
    }

    func test_whenGetAllAssisatnts_returnAllAssistants() {
        // Given
        sut.insert(models: [mockModel(id: 1, participantId: 123, block: true),
                            mockModel(id: 2, participantId: 1234, block: true),
                            mockModel(id: 3, participantId: 12345, block: false),
                           ])

        // When
        let exp = expectation(description: "Expected to insert 3 items in assistant store and fetch 3 items.")
        notification.onInsert { (entities: [CDAssistant]) in
            self.sut.fetch { cacheEntities, count in
                if cacheEntities.count == 3 {
                    exp.fulfill()
                }
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_whenGetBlockedAssisatnts_returnBlockedAssistants() {
        // Given
        sut.insert(models: [mockModel(id: 1, participantId: 123, block: true),
                            mockModel(id: 2, participantId: 1234, block: true),
                            mockModel(id: 3, participantId: 12345, block: false),
                           ])

        // When
        let exp = expectation(description: "Expected to insert 3 items in assistant store and two of them must be blocked.")
        notification.onInsert { (entities: [CDAssistant]) in
            self.sut.getBlocked { cacheEntities, count in
                if cacheEntities.count == 2 {
                    exp.fulfill()
                }
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_whenBlock_blockIsTrue() {
        // Given
        sut.insert(models: [mockModel()])

        // When
        notification.onInsert { (entities: [CDAssistant]) in
            self.sut.block(block: true, assistants: [self.mockModel()])
            self.objectId = entities.first?.objectID
        }

        // Then
        let exp = expectation(description: "Expected the Assistant get blocked object.")
        notification.onUpdate { (entities: [CDAssistant]) in
            if self.objectId == entities.first?.objectID && entities.first?.block?.boolValue == true {
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 1)
    }

    func test_whenUNBlock_blockIsFalse() {
        // Given
        sut.insert(models: [mockModel(block: true)])

        // When
        notification.onInsert { (entities: [CDAssistant]) in
            self.sut.block(block: false, assistants: [self.mockModel()])
            self.objectId = entities.first?.objectID
        }

        // Then
        let exp = expectation(description: "Expected the Assistant get unblocked.")
        notification.onUpdate { (entities: [CDAssistant]) in
            if self.objectId == entities.first?.objectID && entities.first?.block?.boolValue == false {
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 1)
    }

    func test_whenCodableAssistant_requiredFieldsAreFilled() {
        // Given
        sut.insert(models: [mockModel(roles: [.addNewUser])])

        // When
        let exp = expectation(description: "Expected to fillables to be not nil.")
        notification.onInsert { (entities: [CDAssistant]) in
            self.sut.fetch { entities, count in
                let first = entities.first?.codable
                if first?.roles != nil {
                    exp.fulfill()
                }
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_whenIdNil_assistantIdIsGettingFilledByParticipantId() {
        // Given
        sut.insert(models: [mockModel(id: nil, participantId: 123456)])

        // When
        let exp = expectation(description: "Expected the id of assistant to be equal to participantId")
        notification.onInsert { (entities: [CDAssistant]) in
            self.sut.fetch { entities, count in
                let first = entities.first?.codable
                if first?.id == 123456 {
                    exp.fulfill()
                }
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    private func mockModel(id: Int? = 1, participantId: Int = 123456, block: Bool = false, roles: [Roles]? = nil) -> Assistant {
        let participant = Participant(id: participantId)
        let model = Assistant(id: id,
                              assistant: .init(id: "\(20)", idType: .cellphoneNumber),
                              participant: participant,
                              roles: roles,
                              block: block)
        return model
    }

    func log(message: String, persist: Bool, error: Error?) {

    }
}
