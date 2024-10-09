import XCTest
import ChatModels
import CoreData
import Combine
@testable import ChatCache

@available(iOS 13.0, *)
final class CachFileManagerTests: XCTestCase, CacheLogDelegate {

    private var sut: CacheCoreDataFileManager!
    private var cache: CacheManager!
    private var logExpectation = XCTestExpectation(description: "Expected to call log delegate")
    private var notification: MockObjectContextNotificaiton!
    private var objectId: NSManagedObjectID?
    private var cancelables = Set<AnyCancellable>()

    override func setUp() async throws {
        cache = CacheManager(persistentManager: PersistentManager(logger: self))
        _ = await cache.switchToContainer(userId: 1)
        sut = cache.file
        notification = MockObjectContextNotificaiton(context: sut.viewContext)
    }

    func test_whenFileInfo_isInStore() {
        // Given
        sut.insert(models: [mockModel()])

        // When
        let exp = expectation(description: "Expected to insert a file in to the store.")
        notification.onInsert { (entities: [CDFile]) in
            if entities.count > 0 {
                exp.fulfill()
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_whenFetchAFileWithHashCode_itReturnTheFile() {
        // Given
        sut.insert(models: [mockModel(hashCode: "TEST")])

        // When
        let exp = expectation(description: "Expected to fetch a file with TEST hashCode.")
        notification.onInsert { (entities: [CDFile]) in
            self.sut.first(hashCode: "TEST") { model in
                if model?.hashCode == "TEST" {
                    exp.fulfill()
                }
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_whenDuplicateInsertHashCode_existOnlyOneItemInSotre() {
        // Given
        sut.insert(models: [mockModel(hashCode: "TEST")])
        sut.insert(models: [mockModel(hashCode: "TEST", name: "Updated")])

        // When
        let exp = expectation(description: "Expected to find only one item in the store.")
        notification.onInsert { (entities: [CDFile]) in
            let req = CDFile.fetchRequest()
            req.predicate = NSPredicate(format: "%K == %@", #keyPath(CDFile.hashCode) ,"TEST")
            let count = (try? self.sut.viewContext.fetch(req).count) ?? 0
            if count == 1 {
                exp.fulfill()
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    private func mockModel(
        hashCode: String? = "XMXMXMXMX",
        name: String? = "test.pdf",
        size: Int? = 1024,
        type: String? = "application/pdf"
    ) -> File {
        File(hashCode: hashCode,
             name: name,
             size: size,
             type: type)
    }

    func log(message: String, persist: Bool, error: Error?) {

    }
}
