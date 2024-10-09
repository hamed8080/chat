import XCTest
import ChatModels
import CoreData
import Combine
@testable import ChatCache

@available(iOS 13.0, *)
final class CacheImageManagerTests: XCTestCase, CacheLogDelegate {

    private var sut: CacheImageManager!
    private var cache: CacheManager!
    private var logExpectation = XCTestExpectation(description: "Expected to call log delegate")
    private var notification: MockObjectContextNotificaiton!
    private var objectId: NSManagedObjectID?
    private var cancelables = Set<AnyCancellable>()

    override func setUp() async throws {
        cache = CacheManager(persistentManager: PersistentManager(logger: self))
        _ = await cache.switchToContainer(userId: 1)
        sut = cache.image
        notification = MockObjectContextNotificaiton(context: sut.viewContext)
    }

    func test_whenImageInfo_isInStore() {
        // Given
        sut.insert(models: [mockModel()])

        // When
        let exp = expectation(description: "Expected to insert a image in to the store.")
        notification.onInsert { (entities: [CDImage]) in
            if entities.count > 0 {
                exp.fulfill()
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_whenFetchAImageWithHashCode_itReturnTheImage() {
        // Given
        sut.insert(models: [mockModel(hashCode: "TEST")])

        // When
        let exp = expectation(description: "Expected to fetch a image with TEST hashCode.")
        notification.onInsert { (entities: [CDImage]) in
            self.sut.first(hashCode: "TEST") { model in
                if model?.hashCode == "TEST" {
                    exp.fulfill()
                }
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_whenDuplicateInsertImageHashCode_existOnlyOneItemInSotre() {
        // Given
        sut.insert(models: [mockModel(hashCode: "TEST")])
        sut.insert(models: [mockModel(hashCode: "TEST", name: "Updated")])

        // When
        let exp = expectation(description: "Expected to find only one item in the store.")
        notification.onInsert { (entities: [CDImage]) in
            let req = CDImage.fetchRequest()
            req.predicate = NSPredicate(format: "%K == %@", #keyPath(CDImage.hashCode) ,"TEST")
            let count = (try? self.sut.viewContext.fetch(req).count) ?? 0
            if count == 1 {
                exp.fulfill()
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    private func mockModel(
        actualWidth: Int? = 480,
        actualHeight: Int? = 640,
        width: Int? = 480,
        height: Int? = 640,
        hashCode: String? = "XMXMXMXMX",
        name: String? = "test.pdf",
        size: Int? = 1024,
        type: String? = "application/pdf"
    ) -> Image {
        Image(actualWidth: actualWidth,
              actualHeight: actualHeight,
              height: height,
              width: width,
              size: size,
              name: name,
              hashCode: hashCode)
    }

    func log(message: String, persist: Bool, error: Error?) {

    }
}
