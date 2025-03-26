import XCTest
import ChatModels
import CoreData
import Combine
@testable import ChatCache

@available(iOS 13.0, *)
final class CacheCurrentUserRolesManagerTests: XCTestCase, CacheLogDelegate {

    private var sut: CacheCurrentUserRoleManager!
    private var cache: CacheManager!
    private var logExpectation = XCTestExpectation(description: "Expected to call log delegate")
    private var notification: MockObjectContextNotificaiton!
    private var objectId: NSManagedObjectID?
    private var cancelables = Set<AnyCancellable>()

    override func setUp() async throws {
        cache = CacheManager(persistentManager: PersistentManager(logger: self))
        _ = await cache.switchToContainer(userId: 1)
        sut = cache.userRole
        notification = MockObjectContextNotificaiton(context: sut.viewContext)
    }

    func test_whenInsertUserRoles_userRolesAreInStore() {
        // Given
        let roles: [Roles] = [.addNewUser, .deleteMessageOfOthers, .ownership]
        let userRole = UserRole(threadId: 1, roles: roles)
        sut.insert(models: [userRole])

        // When
        let exp = expectation(description: "Expected to insert a user role in to the store.")
        notification.onInsert { (entities: [CDCurrentUserRole]) in
            if entities.count > 0 {
                exp.fulfill()
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_whenGetCurrentUserThreadRoles_returnOnlyThreadRoles() {
        // Given
        let roles1: [Roles] = [.addNewUser, .deleteMessageOfOthers, .ownership]
        let roles2: [Roles] = []
        let userRole1 = UserRole(threadId: 1, roles: roles1)
        let userRole2 = UserRole(threadId: 2, roles: roles2)
        sut.insert(models: [userRole1, userRole2])

        // When
        let exp = expectation(description: "Expected to fetch only one userRole from the store.")
        notification.onInsert { (entities: [CDCurrentUserRole]) in
            if self.sut.roles(1).count == 3 {
                exp.fulfill()
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_whenUserDeletedAUserRole_itReturnNil() {
        // Given
        let roles: [Roles] = [.addNewUser, .deleteMessageOfOthers, .ownership]
        let userRole = UserRole(threadId: 1, roles: roles)
        sut.insert(models: [userRole])

        // When
        let exp = expectation(description: "Expected get nil for the user.")
        notification.onInsert { (entities: [CDCurrentUserRole]) in
            self.sut.batchDelete([1])

        }
        
        notification.onDeletedIds { objectIds in
            if self.sut.roles(1).count == 0 {
                exp.fulfill()
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func log(message: String, persist: Bool, error: Error?) {

    }
}
