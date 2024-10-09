//import XCTest
//import ChatModels
//import CoreData
//import Combine
//@testable import ChatCache
//
//@available(iOS 13.0, *)
//final class CacheReactionCountManagerTests: XCTestCase, CacheLogDelegate {
//    var sut: CacheReactionCountManager!
//    var cache: CacheManager!
//    var logExpectation = XCTestExpectation(description: "Expected to call log delegate")
//    var notification: MockObjectContextNotificaiton!
//    var objectId: NSManagedObjectID?
//
//    override func setUpWithError() throws {
//        cache = CacheManager(persistentManager: PersistentManager(logger: self))
//        cache.switchToContainer(userId: 1)
//        sut = cache.reactionCount
//        notification = MockObjectContextNotificaiton(context: sut.viewContext)
//    }
//
//    func test_whenInsertReactionCountList_isInStore() {
//        // Given
//        sut.insert(models: [mockModel()])
//
//        // When
//        let exp = expectation(description: "Expected to insert an ReactionCountList to store.")
//        notification.onInsert { (entities: [CDReactionCountList]) in
//            if entities.count > 0 {
//                exp.fulfill()
//            }
//        }
//
//        // Then
//        wait(for: [exp], timeout: 1)
//    }
//
//    func test_whenGetAllReactionCountList_returnAllReactionCountList() {
//        // Given
//        let models = [mockModel(messageId: 1, reactionCounts: [.init(sticker: 1, count: 1)]),
//         mockModel(messageId: 2, reactionCounts: [.init(sticker: 2, count: 2)]),
//         mockModel(messageId: 3, reactionCounts: [.init(sticker: 3, count: 3)]),
//        ]
//        sut.insert(models: models)
//
//        // When
//        let exp = expectation(description: "Expected to insert 3 items in ReactionCountList store and fetch 3 items.")
//        notification.onInsert { (entities: [CDReactionCountList]) in
//            self.sut.fetch(models.compactMap({$0.messageId})) { cacheEntities in
//                if cacheEntities.count == 3 {
//                    exp.fulfill()
//                }
//            }
//        }
//
//        // Then
//        wait(for: [exp], timeout: 1)
//    }
//
//    func test_whenCodableReactionCountList_requiredFieldsAreFilled() {
//        // Given
//        let models = [mockModel()]
//        sut.insert(models: models)
//
//        // When
//        let exp = expectation(description: "Expected to fillables to be not nil.")
//        notification.onInsert { (entities: [CDReactionCountList]) in
//            self.sut.fetch(models.compactMap({$0.messageId})) { entities in
//                let first = entities.first?.codable
//                if first?.reactionCounts != nil, first?.messageId == 1 {
//                    exp.fulfill()
//                }
//            }
//        }
//
//        // Then
//        wait(for: [exp], timeout: 1)
//    }
//
//    func test_whenDeleteAReaction_reduceTheReactionCount() {
//        // Given
//        let models = [mockModel(messageId: 1, reactionCounts: [.init(sticker: 1, count: 4), .init(sticker: 2, count: 6)])]
//        sut.insert(models: models)
//
//        // When
//        let exp = expectation(description: "Expected to fillables to be not nil.")
//        notification.onInsert { (entities: [CDReactionCountList]) in
//            self.sut.setReactionCount(messageId: 1, reaction: 2, action: .decrease)
//        }
//
//        notification.onUpdate { (entities: [CDReactionCountList]) in
//            if entities.first?.codable.reactionCounts?.first(where: {$0.sticker == 2 })?.count == 5 {
//                exp.fulfill()
//            }
//        }
//
//        // Then
//        wait(for: [exp], timeout: 1)
//    }
//
//    func test_whenAddAReaction_increaseTheReactionCount() {
//        // Given
//        let models = [mockModel(messageId: 1, reactionCounts: [.init(sticker: 1, count: 4), .init(sticker: 2, count: 6)])]
//        sut.insert(models: models)
//
//        // When
//        let exp = expectation(description: "Expected to fillables to be not nil.")
//        notification.onInsert { (entities: [CDReactionCountList]) in
//            self.sut.setReactionCount(messageId: 1, reaction: 2, action: .increase)
//        }
//
//        notification.onUpdate { (entities: [CDReactionCountList]) in
//            if entities.first?.codable.reactionCounts?.first(where: {$0.sticker == 2 })?.count == 7 {
//                exp.fulfill()
//            }
//        }
//
//        // Then
//        wait(for: [exp], timeout: 1)
//    }
//
//    func test_whenSetAReactionCount_setTheReactionCount() {
//        // Given
//        let models = [mockModel(messageId: 1, reactionCounts: [.init(sticker: 1, count: 4), .init(sticker: 2, count: 6)])]
//        sut.insert(models: models)
//
//        // When
//        let exp = expectation(description: "Expected to fillables to be not nil.")
//        notification.onInsert { (entities: [CDReactionCountList]) in
//            self.sut.setReactionCount(messageId: 1, reaction: 2, action: .set(9))
//        }
//
//        notification.onUpdate { (entities: [CDReactionCountList]) in
//            if entities.first?.codable.reactionCounts?.first(where: {$0.sticker == 2 })?.count == 9 {
//                exp.fulfill()
//            }
//        }
//
//        // Then
//        wait(for: [exp], timeout: 1)
//    }
//
//    private func mockModel(messageId: Int? = 1, reactionCounts: [ReactionCount]? = [.init(sticker: 1, count: 4)]) -> ReactionCountList {
//        let model = ReactionCountList(messageId: messageId, reactionCounts: reactionCounts)
//        return model
//    }
//
//    func log(message: String, persist: Bool, error: Error?) {
//
//    }
//}
