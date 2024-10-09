import XCTest
import ChatModels
import CoreData
import Combine
@testable import ChatCache

@available(iOS 13.0, *)
final class CacheUserManagerTests: XCTestCase, CacheLogDelegate {

    private var sut: CacheUserManager!
    private var cache: CacheManager!
    private var logExpectation = XCTestExpectation(description: "Expected to call log delegate")
    private var notification: MockObjectContextNotificaiton!
    private var objectId: NSManagedObjectID?
    private var cancelables = Set<AnyCancellable>()

    override func setUp() async throws {
        cache = CacheManager(persistentManager: PersistentManager(logger: self))
        _ = await cache.switchToContainer(userId: 1)
        sut = cache.user
        notification = MockObjectContextNotificaiton(context: sut.viewContext)
    }

    func test_whenInsertUser_userIsInStore() {
        // Given
        sut.insert(models: [mockModel()])

        // When
        let exp = expectation(description: "Expected to insert a user in to the store.")
        notification.onInsert { (entities: [CDUser]) in
            if entities.count > 0 {
                exp.fulfill()
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_whenInsertCurrentUserIsMe_userIsInStore() {
        // Given
        sut.insert(mockModel(), isMe: true)

        // When
        let exp = expectation(description: "Expected to insert me as the currentUser in to the store.")
        notification.onInsert { (entities: [CDUser]) in
            if entities.first?.isMe == true {
                exp.fulfill()
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_whenFetchCurrentUser_itReurnOnlyOneUser() {
        // Given
        sut.insert(mockModel(id: 1), isMe: true)
        sut.insert(mockModel(id: 2), isMe: false)
        sut.insert(models: [mockModel(id: 3), mockModel(id: 4)])

        // When
        let exp = expectation(description: "Expected to fetch only one user as the main user in the whole user table.")
        exp.expectedFulfillmentCount = 3
        notification.onInsert { (entities: [CDUser]) in
            self.sut.fetchCurrentUser { entity in
                if entity?.isMe == true, entity?.id == 1 {
                    exp.fulfill()
                }
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_whenCodableUser_requiredFieldsAreNotEmpty() {
        // Given
        sut.insert(mockModel(), isMe: true)

        // When
        let exp = expectation(description: "Expected to fillables to be not nil.")
        notification.onInsert { (entities: [CDUser]) in
            let first = entities.first?.codable
            if first?.id != nil {
                exp.fulfill()
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    private func mockModel(
        cellphoneNumber: String? = "+1235256334",
        coreUserId: Int? = nil,
        email: String? = nil,
        id: Int? = 1,
        image: String? = nil,
        lastSeen: Int? = Int(Date().timeIntervalSince1970),
        name: String? = "John Doe",
        nickname: String? = "John",
        receiveEnable: Bool? = nil,
        sendEnable: Bool? = nil,
        username: String? = "j.john",
        ssoId: String? = nil,
        firstName: String? = "John",
        lastName: String? = "Doe",
        profile: Profile? = nil
    ) -> User {
        User(cellphoneNumber: cellphoneNumber,
             coreUserId: coreUserId,
             email: email,
             id: id,
             image: image,
             lastSeen: lastSeen,
             name: name,
             nickname: nickname,
             receiveEnable: receiveEnable,
             sendEnable: sendEnable,
             username: username,
             ssoId: ssoId,
             firstName: firstName,
             lastName: lastName,
             profile: profile)
    }

    func log(message: String, persist: Bool, error: Error?) {

    }
}
