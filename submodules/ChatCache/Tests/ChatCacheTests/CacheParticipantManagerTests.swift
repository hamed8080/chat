import XCTest
import ChatModels
import CoreData
import Combine
@testable import ChatCache

@available(iOS 13.0, *)
final class CacheParticipantManagerTests: XCTestCase, CacheLogDelegate {

    private var sut: CacheParticipantManager!
    private var cache: CacheManager!
    private var logExpectation = XCTestExpectation(description: "Expected to call log delegate")
    private var notification: MockObjectContextNotificaiton!
    private var objectId: NSManagedObjectID?
    private var cancelables = Set<AnyCancellable>()

    override func setUp() async throws {
        cache = CacheManager(persistentManager: PersistentManager(logger: self))
        _ = await cache.switchToContainer(userId: 1)
        sut = cache.participant
        notification = MockObjectContextNotificaiton(context: sut.viewContext)
    }

    func test_whenInsertParticipant_isInStore() {
        // Given
        sut.insert(model: Conversation(id: 1, participants: [mockModel(id: 1)]))

        // When
        let exp = expectation(description: "Expected to insert a participant in to the store.")
        notification.onInsert { (entities: [CDParticipant]) in
            self.sut.first(1, 1) { participant in
                if participant != nil {
                    exp.fulfill()
                }
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_whenGetThreadParticipants_itReturnOnlyTenParitcipants() {
        // Given
        let threadOneParticipants = (1...20).map{ mockModel(id: $0) }
        let threadTwoParticipants = (1...20).map{ mockModel(id: $0, conversation: Conversation(id: 2)) }
        sut.insert(model: Conversation(id: 1, participants: threadOneParticipants))
        sut.insert(model: Conversation(id: 2, participants: threadTwoParticipants))

        // When
        let exp = expectation(description: "Expected to get participants of a specific thread with count and offset.")
        notification.onInsert { (entities: [CDConversation]) in
            if entities.first?.id == 1 {
                self.sut.getThreadParticipants(1, 10, 0) { participantsEntity, totalCount in
                    if participantsEntity.count == 10, totalCount == 20, participantsEntity.first?.conversation?.id == 1 {
                        exp.fulfill()
                    }
                }
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_whenAtThreadWithNilId_nothingIsInserted() {
        // Given
        sut.insert(model: Conversation(id: nil, participants: [mockModel(id: 1, conversation: Conversation(id: nil))]))

        // When
        let exp = expectation(description: "Expected to neither insert a participant or conversation in to the store.")
        exp.isInverted = true
        notification.onInsert { (entities: [CDConversation]) in
            let preq = CDParticipant.fetchRequest()
            let creq = CDConversation.fetchRequest()
            let participantCount = (try? self.sut.viewContext.fetch(preq).count) ?? 0
            let conversationCount = (try? self.sut.viewContext.fetch(creq).count) ?? 0
            if participantCount > 0, conversationCount > 0 {
                exp.fulfill()
            }
        }

        // Then
        wait(for: [exp], timeout: 0.5)
    }

    func test_whenDeleteAParticipant_participantIsDeleted() {
        // Given
        sut.insert(model: Conversation(id: 1, participants: [mockModel(id: 1)]))

        // When
        let exp = expectation(description: "Expected to delete a participant from the store where the thread Id is 1.")
        notification.onInsert { (entities: [CDConversation]) in
            self.sut.delete([.init(id: 1)], 1)
        }

        notification.onDeletedIds { (objectIds: [NSManagedObjectID]) in
            self.sut.first(1, 1) { participant in
                if participant == nil {
                    exp.fulfill()
                }
            }
        }

        // Then
        wait(for: [exp], timeout: 0.5)
    }

    func test_whenDeleteAParticipant_onlyDeleteParticipantThatBelongToAThread() {
        // Given
        sut.insert(model: Conversation(id: 1, participants: [mockModel(id: 1)]))
        sut.insert(model: Conversation(id: 2, participants: [mockModel(id: 1, conversation: Conversation(id: 2))]))

        // When
        let exp = expectation(description: "Expected to delete a participant from the store where the thread Id is 1.")
        notification.onInsert { (entities: [CDConversation]) in
            self.sut.delete([.init(id: 1)], 1)
        }

        notification.onDeletedIds { (objectIds: [NSManagedObjectID]) in
            self.sut.first(2, 1) { participant in
                if participant != nil {
                    exp.fulfill()
                }
            }
        }

        // Then
        wait(for: [exp], timeout: 0.5)
    }

    func test_whenDeleteAThread_allThreadParticipantsDeleted() {
        // Given
        sut.insert(model: Conversation(id: 1, participants: [mockModel(id: 1), mockModel(id: 2)]))
        sut.insert(model: Conversation(id: 2, participants: [mockModel(id: 1, conversation: Conversation(id: 2))]))

        // When
        let exp = expectation(description: "Expected to delete participants of a thread when a thread deleted.")
        notification.onInsert { (entities: [CDConversation]) in
            self.cache.conversation?.delete(1)
        }

        notification.onDeletedIds { (objectIds: [NSManagedObjectID]) in
            self.sut.getThreadParticipants(1, 10, 0) { threadParticipants, totalCount in
                if totalCount == 0, threadParticipants.count == 0 {
                    exp.fulfill()
                }
            }
        }

        // Then
        wait(for: [exp], timeout: 0.5)
    }

    func test_whenCodableAParticipant_fillableAreNotNill() {
        // Given
        sut.insert(model: Conversation(id: 1, participants: [mockModel(id: 1, roles: [.addNewUser])]))

        // When
        let exp = expectation(description: "Expected to fillables to be not nil.")
        notification.onInsert { (entities: [CDParticipant]) in
            self.sut.getThreadParticipants(1) { entities, _ in
                if entities.first?.codable.roles != nil {
                    exp.fulfill()
                }
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_whenSetAdminRole_itSetAdminToTrue() {
        // Given
        sut.insert(model: Conversation(id: 1, participants: [Participant(admin: false, id: 1)]))

        // When
        let exp = expectation(description: "Expected to set admin to true.")
        notification.onInsert { (entities: [CDParticipant]) in
            self.sut.addAdminRole(participantIds: [1])
        }

        notification.onUpdateIds { entities in
            self.sut.first(1, 1) { entity in
                if entity?.admin == true {
                    exp.fulfill()
                }
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_whenRemoveAdminRole_itSetAdminToFalse() {
        // Given
        sut.insert(model: Conversation(id: 1, participants: [Participant(admin: true, id: 1)]))

        // When
        let exp = expectation(description: "Expected to set admin to true.")
        notification.onInsert { (entities: [CDParticipant]) in
            self.sut.removeAdminRole(participantIds: [1])
        }

        notification.onUpdateIds { entities in
            self.sut.first(1, 1) { entity in
                if entity?.admin == false {
                    exp.fulfill()
                }
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    private func mockModel(
        admin: Bool? = nil,
        auditor: Bool? = nil,
        blocked: Bool? = nil,
        cellphoneNumber: String? = nil,
        contactFirstName: String? = nil,
        contactId: Int? = nil,
        contactName: String? = nil,
        contactLastName: String? = nil,
        coreUserId: Int? = nil,
        email: String? = nil,
        firstName: String? = nil,
        id: Int? = 1,
        ssoId: String? = nil,
        image: String? = nil,
        keyId: String? = nil,
        lastName: String? = nil,
        myFriend: Bool? = nil,
        name: String? = "John Doe",
        notSeenDuration: Int? = nil,
        online: Bool? = nil,
        receiveEnable: Bool? = nil,
        roles: [Roles]? = nil,
        sendEnable: Bool? = nil,
        username: String? = "j.john",
        chatProfileVO: Profile? = nil,
        conversation: Conversation? = Conversation(id: 1)
    ) -> Participant {
        return Participant(admin: admin,
                           auditor: auditor,
                           blocked: blocked,
                           cellphoneNumber: cellphoneNumber,
                           contactFirstName: contactFirstName,
                           contactId: contactId,
                           contactName: contactName,
                           contactLastName: contactLastName,
                           coreUserId: coreUserId,
                           email: email,
                           firstName: firstName,
                           id: id,
                           ssoId: ssoId,
                           image: image,
                           keyId: keyId,
                           lastName: lastName,
                           myFriend: myFriend,
                           name: name,
                           notSeenDuration: notSeenDuration,
                           online: online,
                           receiveEnable: receiveEnable,
                           roles: roles,
                           sendEnable: sendEnable,
                           username: username,
                           chatProfileVO: chatProfileVO,
                           conversation: conversation?.toParticipantConversation)
    }

    func log(message: String, persist: Bool, error: Error?) {

    }
}
