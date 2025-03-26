import XCTest
import ChatModels
import CoreData
import Combine
@testable import ChatCache

@available(iOS 13.0, *)
final class CacheContactManagerTests: XCTestCase, CacheLogDelegate {
    var sut: CacheContactManager!
    var cache: CacheManager!
    var logExpectation = XCTestExpectation(description: "Expected to call log delegate")
    var notification: MockObjectContextNotificaiton!
    var objectId: NSManagedObjectID?

    override func setUp() async throws {
        cache = CacheManager(persistentManager: PersistentManager(logger: self))
        _ = await cache.switchToContainer(userId: 1)
        sut = cache.contact
        notification = MockObjectContextNotificaiton(context: sut.viewContext)
    }

    func test_whenBatchInsert_persistedInStore() {
        // Given
        let models = [mockModel(id: 1), mockModel(id: 2)]
        sut.insert(models: models)

        // When
        let exp = expectation(description: "Expected to insert two contacts.")
        notification.onInsert { (entities: [CDContact]) in
            if entities.count == 2 {
                exp.fulfill()
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_whenDelete_contactIsDeleted() {
        // Given
        let models = [mockModel(id: 1), mockModel(id: 2)]
        sut.insert(models: models)

        // When
        notification.onInsert { (entities: [CDContact]) in
            self.sut.batchDelete(models.compactMap{$0.id})
        }

        // Then
        let exp = expectation(description: "Expected to insert two contacts and then delete two contacts.")
        notification.onDeletedIds { objectIds in
            if objectIds.count == 2 {
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 1)
    }

    func test_whenBlock_contactIsBlocked() {
        // Given
        let models = [mockModel(id: 1), mockModel(id: 2)]
        sut.insert(models: models)

        // When
        notification.onInsert { (entities: [CDContact]) in
            self.sut.block(true, 1)
        }

        // Then
        let exp = expectation(description: "Expected to block the contact.")
        notification.onUpdateIds { objectIds in
            self.sut.fetchWithObjectIds(ids: objectIds) { entities in
                if entities.first?.blocked == true {
                    exp.fulfill()
                }
            }
        }
        wait(for: [exp], timeout: 1)
    }

    func test_whenUnBlock_contactIsUnBlocked() {
        // Given
        let models = [mockModel(block: true, id: 1), mockModel(id: 2)]
        sut.insert(models: models)

        // When
        notification.onInsert { (entities: [CDContact]) in
            self.sut.block(false, 1)
        }

        // Then
        let exp = expectation(description: "Expected to unblock a blocked contact.")
        notification.onUpdateIds { objectIds in
            self.sut.fetchWithObjectIds(ids: objectIds) { entities in
                if entities.first?.blocked == false {
                    exp.fulfill()
                }
            }
        }
        wait(for: [exp], timeout: 1)
    }

    func test_whenGetContacts_withEmailReturnAndContact() {
        // Given
        let models = [mockModel(email: "test@gmail.com"), mockModel(id: 2)]
        sut.insert(models: models)

        // When
        let exp = expectation(description: "Expected to get a contact with an email.")
        notification.onInsert() { (entities: [CDContact]) in
            self.sut.getContacts(.init(email: "test@gmail.com")) { entities, total in
                if entities.first?.email == "test@gmail.com", entities.count == 1 {
                    exp.fulfill()
                }
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_whenGetContacts_withMobileNumberReturnAndContact() {
        // Given
        let models = [mockModel(cellPhoneNumber: "09369161601"), mockModel(id: 2)]
        sut.insert(models: models)

        // When
        let exp = expectation(description: "Expected to get a contact with mobile.")
        notification.onInsert() { (entities: [CDContact]) in
            self.sut.getContacts(.init(cellphoneNumber: "09369161601")) { entities, total in
                if entities.first?.cellphoneNumber == "09369161601", entities.count == 1 {
                    exp.fulfill()
                }
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_whenGetContacts_withContactIdReturnAndContact() {
        // Given
        let models = [mockModel(id: 1), mockModel(id: 2)]
        sut.insert(models: models)

        // When
        let exp = expectation(description: "Expected to get a contact with an id.")
        notification.onInsert() { (entities: [CDContact]) in
            self.sut.getContacts(.init(id: 1)) { entities, total in
                if entities.first?.id == 1, entities.count == 1 {
                    exp.fulfill()
                }
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_whenGetContacts_withFirstNameReturnAndContact() {
        // Given
        let entity = CDContact.insertEntity(sut.viewContext)
        entity.firstName = "John"
        entity.lastName = "Doe"
        sut.viewContext.perform {
            try? self.sut.viewContext.save()
        }

        // When
        let exp = expectation(description: "Expected to get a contact with firstName.")
        notification.onInsert { (entities: [CDContact]) in
            self.sut.getContacts(.init(query: "John")) { entities, total in
                if (entities.first(where: {$0.firstName == "John" }) != nil)  {
                    exp.fulfill()
                }
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_whenGetContacts_withLastNameReturnAndContact() {
        // Given
        let entity = CDContact.insertEntity(sut.viewContext)
        entity.firstName = "John"
        entity.lastName = "Doe"
        sut.viewContext.perform {
            try? self.sut.viewContext.save()
        }

        // When
        let exp = expectation(description: "Expected to get a contact with lastName.")
        notification.onInsert { (entities: [CDContact]) in
            self.sut.getContacts(.init(query: "Doe")) { entities, total in
                if (entities.first(where: {$0.lastName == "Doe" }) != nil)  {
                    exp.fulfill()
                }
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_whenThereIsNoContact_totalCountZero() {
        // When
        let entity = CDContact.insertEntity(sut.viewContext)
        entity.firstName = "John"
        entity.lastName = "Doe"
        sut.viewContext.perform {
            try? self.sut.viewContext.save()
        }

        let exp = expectation(description: "Expected to get zero for total count.")
        notification.onInsert { (entities: [CDContact]) in
            self.sut.getContacts(.init(query: "Doe")) { entities, total in
                if total != 0  {
                    exp.fulfill()
                }
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_whenGetContacts_totalCountIsNotZero() {
        // When
        let exp = expectation(description: "Expected to get not zero for total count.")
        self.sut.getContacts(.init(query: "John")) { entities, total in
            if total == 0  {
                exp.fulfill()
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_whenCodableContact_requiredFieldsAreNotNil() {
        // Given
        sut.insert(models: [mockModel()])

        // When
        let exp = expectation(description: "Expected to fillables to be not nil.")
        notification.onInsert { (entities: [CDContact]) in
            self.sut.getContacts(.init()) { entities, totalCount in
                let codable = entities.first?.codable
                if codable?.id != nil {
                    exp.fulfill()
                }
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    private func mockModel(block: Bool = false, id: Int = 123456, email: String? = nil, cellPhoneNumber: String? = "0912+++") -> Contact {
        return Contact(blocked: block,
                       cellphoneNumber: cellPhoneNumber,
                       email: email,
                       firstName: "John",
                       hasUser: true,
                       id: id,
                       image: nil,
                       lastName: "Doe",
                       user: nil,
                       notSeenDuration: 0,
                       time: 0,
                       userId: 1
        )
    }

    func log(message: String, persist: Bool, error: Error?) {

    }
}
