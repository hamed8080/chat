import XCTest
import ChatModels
import CoreData
import Combine
@testable import ChatCache

@available(iOS 13.0, *)
final class BaseCoreDataManagerTests: XCTestCase, CacheLogDelegate {
    var sut: CacheConversationManager!
    var cache: CacheManager!
    var logExpectation = XCTestExpectation(description: "Expected to call log delegate")
    var notification: MockObjectContextNotificaiton!
    var objectId: NSManagedObjectID?

    override func setUp() async throws {
        cache = CacheManager(persistentManager: PersistentManager(logger: self))
        _ = await cache.switchToContainer(userId: 1)
        sut = cache.conversation
        notification = MockObjectContextNotificaiton(context: sut.viewContext)
    }

    func test_whenAnErrorThrown_itWillLogged() {
        //If the thread id is null it should raise an exception
        let thread = CDConversation.insertEntity(sut.viewContext)
        thread.title = "test"
        sut.saveViewContext()
        wait(for: [logExpectation], timeout: 1)
    }

    func test_whenSaveThereIsNoChanges_itWillLogged() {
        sut.saveViewContext()
        wait(for: [logExpectation], timeout: 1)
    }

    func test_whenInsertBatchOperation_itWillNotify() {
        sut.insertObjects { context in
            let thread1 = CDConversation.insertEntity(context)
            thread1.id = 1
            let thread2 = CDConversation.insertEntity(context)
            thread2.id = 2
        }
        wait(for: [logExpectation], timeout: 1)
    }

    func log(message: String, persist: Bool, error: Error?) {
        logExpectation.fulfill()
    }
}
