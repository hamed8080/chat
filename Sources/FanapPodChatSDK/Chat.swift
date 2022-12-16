//
// Chat.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation
import Sentry

public class ChatManager {
    private init() {}
    public static var instance: ChatManager = .init()
    public static var activeInstance: Chat!
    private var instances: [UUID: Chat] = [:]

    public func createInstance(config: ChatConfig) {
        let chat = Chat(config: config)
        instances[chat.id] = chat
        ChatManager.activeInstance = chat
    }

    public func switchInstance(chatId: UUID) {
        ChatManager.activeInstance = instances[chatId]
    }

    public func removeInstance(chatId: UUID) {
        instances.removeValue(forKey: chatId)
    }
}

protocol DispatchQueueProtocol {
    func async(execute work: @escaping @convention(block) () -> Void)
}

protocol URLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
    func decode<T: Decodable>(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> ChatResponse<T>
}

extension DispatchQueue: DispatchQueueProtocol {
    func async(execute work: @escaping @convention(block) () -> Void) {
        async(group: nil, qos: .unspecified, flags: [], execute: work)
    }
}

extension URLSession: URLSessionProtocol {}

extension URLSessionProtocol {
    func decode<T: Decodable>(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> ChatResponse<T> {
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
        if let data = data, let chatError = try? JSONDecoder().decode(ChatError.self, from: data), chatError.hasError == true {
            return ChatResponse(error: chatError)
        } else if statusCode >= 200, statusCode <= 300, let data = data, let codable = try? JSONDecoder().decode(T.self, from: data) {
            return ChatResponse(result: codable)
        } else if let error = error {
            let error = ChatError(message: "\(ChatErrorCodes.networkError.rawValue) \(error)", errorCode: statusCode, hasError: true)
            return ChatResponse(error: error)
        } else {
            let error = ChatError(message: "\(ChatErrorCodes.networkError.rawValue)", errorCode: statusCode, hasError: true)
            return ChatResponse(error: error)
        }
    }
}

protocol ChatProtocol {
    var id: UUID { get set }
    var config: ChatConfig { get set }
    var isTypingCount: Int { get set }
    var timerTyping: TimerProtocol? { get set }
    var requestUserTimer: TimerProtocol { get set }
    var timerCheckUserStoppedTyping: TimerProtocol? { get set }
    var exportMessageViewModels: [any ExportMessagesProtocol] { get set }
    var session: URLSessionProtocol { get set }
    var responseQueue: DispatchQueueProtocol { get set }
    var cache: CacheFactory { get set }
    var cacheFileManager: CacheFileManager { get }
    var userRetrycount: Int { get set }
    var maxUserRetryCount: Int { get }
    var webrtc: WebRTCClient? { get set }
    var callDelegate: WebRTCClientDelegate? { get set }
}

struct Voidcodable: Codable {}

protocol TimerProtocol {
    init(timeInterval interval: TimeInterval, repeats: Bool, block: @escaping @Sendable (Timer) -> Void)
    func scheduledTimer(withTimeInterval interval: TimeInterval, repeats: Bool, block: @escaping @Sendable (Timer) -> Void) -> Timer
    func invalidate()
}

extension Timer: TimerProtocol {
    func scheduledTimer(withTimeInterval interval: TimeInterval, repeats: Bool, block: @escaping @Sendable (Timer) -> Void) -> Timer {
        Timer.scheduledTimer(withTimeInterval: interval, repeats: repeats, block: block)
    }
}

public class Chat: ChatProtocol, Identifiable {
    public var id: UUID = .init()
    public var config: ChatConfig
    let callbacksManager = CallbacksManager()
    internal var asyncManager: AsyncManager
    internal var logger: Logger?
    var isTypingCount = 0
    var timerTyping: TimerProtocol?
    var requestUserTimer: TimerProtocol
    var timerCheckUserStoppedTyping: TimerProtocol?
    var callStartTimer: TimerProtocol?
    var exportMessageViewModels: [any ExportMessagesProtocol] = []
    /// Current user info of the application it'll be filled after chat is in the ``ChatState/chatReady``  state.
    public private(set) var userInfo: User?
    var session: URLSessionProtocol
    /// Delegate to send events.
    public weak var delegate: ChatDelegate?
    var responseQueue: DispatchQueueProtocol
    var cache: CacheFactory
    var cacheFileManager: CacheFileManager { cache.cacheFileManager }
    internal var userRetrycount = 0
    internal let maxUserRetryCount = 5
    var callState: CallState?
    public var webrtc: WebRTCClient?
    public weak var callDelegate: WebRTCClientDelegate?

    init(
        config: ChatConfig,
        logger: Logger? = nil,
        timerTyping: TimerProtocol? = Timer(),
        requestUserTimer: TimerProtocol = Timer(),
        timerCheckUserStoppedTyping: TimerProtocol? = Timer(),
        pingTimer: TimerProtocol = Timer(),
        queueTimer: TimerProtocol = Timer(),
        callStartTimer: TimerProtocol = Timer(),
        callDelegate: WebRTCClientDelegate? = nil,
        session: URLSessionProtocol = URLSession.shared,
        responseQueue: DispatchQueueProtocol = DispatchQueue.main
    ) {
        self.responseQueue = responseQueue
        self.config = config
        self.logger = logger ?? Logger(config: config)
        self.timerTyping = timerTyping
        self.callStartTimer = callStartTimer
        self.requestUserTimer = requestUserTimer
        self.timerCheckUserStoppedTyping = timerCheckUserStoppedTyping
        self.session = session
        self.callDelegate = callDelegate
        cache = CacheFactory(config: config)
        asyncManager = AsyncManager(pingTimer: pingTimer, queueTimer: queueTimer, config: config, delegate: delegate, logger: logger)
        asyncManager.chat = self
    }

    /// Create logger and then connect to async server.
    public func connect() {
        if config.captureLogsOnSentry == true {
            startCrashAnalytics()
        }

        if config.getDeviceIdFromToken == false {
            asyncManager.createAsync()
        } else {
            requestDeviceId()
        }
        _ = DiskStatus.checkIfDeviceHasFreeSpace(needSpaceInMB: config.deviecLimitationSpaceMB, turnOffTheCache: true, errorDelegate: delegate)
    }

    /// Closing the async socket if it is open and setting the chat shared instance to nil.
    /// You should take into consideration that if you need to work with this instance you should call the ``createChatObject(config:)`` method again.
    public func dispose() {
        asyncManager.disposeObject()
        print("Disposed Singleton instance")
    }

    // **************************** Intitializers ****************************

    /// Get contacts of current user.
    /// - Parameters:
    ///   - request: The request.
    ///   - completion: The answer of the request.
    ///   - cacheResponse: Reponse from cache database.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func getContacts(_ request: ContactsRequest, completion: @escaping CompletionType<[Contact]>, cacheResponse: CacheResponseType<[Contact]>? = nil, uniqueIdResult: UniqueIdResultType? = nil) {
        requestContacts(request, completion, cacheResponse, uniqueIdResult)
    }

    /// Get the list of blocked contacts.
    /// - Parameters:
    ///   - request: The request.
    ///   - completion: The answer is the list of blocked contacts.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func getBlockedContacts(_ request: BlockedListRequest, completion: @escaping CompletionType<[BlockedContact]>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestBlockedContacts(request, completion, uniqueIdResult)
    }

    /// Add a new contact.
    /// - Parameters:
    ///   - request: The request.
    ///   - completion: The answer of the request if the contact is added successfully.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func addContact(_ request: AddContactRequest, completion: @escaping CompletionType<[Contact]>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestAddContact(request, completion, uniqueIdResult)
    }

    /// Add multiple contacts at once.
    /// - Parameters:
    ///   - request: The request.
    ///   - completion: The answer of the request if the contacts are added successfully.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func addContacts(_ request: [AddContactRequest], completion: @escaping CompletionType<[Contact]>, uniqueIdsResult: UniqueIdsResultType? = nil) {
        requestAddContacts(request, completion, uniqueIdsResult)
    }

    /// Check the last time a user opened the application.
    /// - Parameters:
    ///   - request: The request with userIds.
    ///   - completion: List of last seen users with time attached to each item.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func contactNotSeen(_ request: NotSeenDurationRequest, completion: @escaping CompletionType<[UserLastSeenDuration]>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestContactNotSeen(request, completion, uniqueIdResult)
    }

    /// Remove a contact from your circle of contacts.
    /// - Parameters:
    ///   - request: The request with userIds.
    ///   - completion: The answer if the contact has been successfully deleted.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func removeContact(_ request: RemoveContactsRequest, completion: @escaping CompletionType<Bool>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestRemoveContact(request, completion, uniqueIdResult)
    }

    /// Search inside contacts.
    ///
    /// You could search inside the list of contacts by email, cell phone number, or a query or a specific id.
    /// - Parameters:
    ///   - request: The request.
    ///   - completion: The answer if the contact has been successfully deleted.
    ///   - cacheResponse: Reponse from cache database.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func searchContacts(_ request: ContactsRequest, completion: @escaping CompletionType<[Contact]>, cacheResponse: CacheResponseType<[Contact]>? = nil, uniqueIdResult: UniqueIdResultType? = nil) {
        getContacts(request, completion: completion, cacheResponse: cacheResponse, uniqueIdResult: uniqueIdResult)
    }

    /// Sync contacts with server.
    ///
    /// If a new contact is added to your device it'll sync the unsynced contacts.
    /// - Parameters:
    ///   - completion: The answer of synced contacts.
    ///   - uniqueIdsResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func syncContacts(completion: @escaping CompletionType<[Contact]>, uniqueIdsResult: UniqueIdsResultType? = nil) {
        requestSyncContacts(completion, uniqueIdsResult)
    }

    /// Update a particular contact.
    ///
    /// Update name or other details of a contact.
    /// - Parameters:
    ///   - req: The request of what you need to be updated.
    ///   - completion: The list of updated contacts.
    ///   - uniqueIdsResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func updateContact(_ req: UpdateContactRequest, completion: @escaping CompletionType<[Contact]>, uniqueIdsResult: UniqueIdResultType? = nil) {
        requestUpdateContact(req, completion, uniqueIdsResult)
    }

    /// Block a specific contact.
    /// - Parameters:
    ///   - request: You could block contact with userId, contactId or you could block a thread.
    ///   - completion: Reponse of blocked request.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func blockContact(_ request: BlockRequest, completion: @escaping CompletionType<BlockedContact>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestBlockContact(request, completion, uniqueIdResult)
    }

    /// Unblock a blcked contact.
    /// - Parameters:
    ///   - request: You could unblock contact with userId, contactId or you could unblock a thread.
    ///   - completion: Reponse of before blocked request.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func unBlockContact(_ request: UnBlockRequest, completion: @escaping CompletionType<BlockedContact>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestUnBlockContact(request, completion, uniqueIdResult)
    }

    /// Convert latitude and longitude to a human-readable address.
    /// - Parameters:
    ///   - request: Request of getting address.
    ///   - completion: Response of reverse address.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func mapReverse(_ request: MapReverseRequest, completion: @escaping CompletionType<MapReverse>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestMapReverse(request, completion, uniqueIdResult)
    }

    /// Search for Items inside an area.
    /// - Parameters:
    ///   - request: Request of area.
    ///   - completion: Reponse of founded items.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func mapSearch(_ request: MapSearchRequest, completion: @escaping CompletionType<[MapItem]>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestMapSearch(request, completion, uniqueIdResult)
    }

    /// Find a route between two places.
    /// - Parameters:
    ///   - request: The request that contains origin and destination.
    ///   - completion: Response of request.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func mapRouting(_ request: MapRoutingRequest, completion: @escaping CompletionType<[Route]>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestMapRouting(request, completion, uniqueIdResult)
    }

    /// Convert a location to an image.
    /// - Parameters:
    ///   - request: The request size and location.
    ///   - completion: Data of image.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func mapStaticImage(_ request: MapStaticImageRequest, _ downloadProgress: DownloadProgressType? = nil, completion: @escaping CompletionType<Data?>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestDownloadMapStatic(request, downloadProgress, uniqueIdResult, completion)
    }

    /// Get list of threads.
    /// - Parameters:
    ///   - request: The request of list of threads.
    ///   - completion: Response of list of threads that came with pagination.
    ///   - cacheResponse: Threads list that came from the cache.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func getThreads(_ request: ThreadsRequest, completion: @escaping CompletionType<[Conversation]>, cacheResponse: CacheResponseType<[Conversation]>? = nil, uniqueIdResult: UniqueIdResultType? = nil) {
        requestThreads(request, completion, cacheResponse, uniqueIdResult)
    }

    /// Getting the all threads.
    /// - Parameters:
    ///   - request: If you send the summary true in request the result only contains list of all thread ids which is much faster way to fetch thread list.
    ///   - completion: Response of list of threads that came with pagination.
    ///   - cacheResponse: Thread cache return data from disk so it contains all data in each model.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func getAllThreads(request: AllThreads, completion: @escaping CompletionType<[Conversation]>, cacheResponse: CacheResponseType<[Conversation]>? = nil, uniqueIdResult: UniqueIdResultType? = nil) {
        requestAllThreads(request, completion, cacheResponse, uniqueIdResult)
    }

    /// Check name for the public thread is not occupied.
    /// - Parameters:
    ///   - request: The request for the name of the thread to check.
    ///   - completion: If thread name is free for using as public it will not be nil.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func isThreadNamePublic(_ request: IsThreadNamePublicRequest, completion: @escaping CompletionType<String>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestIsThreadNamePublic(request, completion, uniqueIdResult)
    }

    /// Mute a thread when a new event happens.
    /// - Parameters:
    ///   - request: The request with a thread id.
    ///   - completion: Response of mute thread.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func muteThread(_ request: GeneralSubjectIdRequest, completion: @escaping CompletionType<Int>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestMuteThread(request, completion, uniqueIdResult)
    }

    /// UNMute a thread.
    /// - Parameters:
    ///   - request: The request with a thread id.
    ///   - completion: Response of unmute thread.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func unmuteThread(_ request: GeneralSubjectIdRequest, completion: @escaping CompletionType<Int>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestUnMuteThread(request, completion, uniqueIdResult)
    }

    /// Pin a thread.
    /// - Parameters:
    ///   - request: The request with a thread id.
    ///   - completion: Response of pin thread.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func pinThread(_ request: GeneralSubjectIdRequest, completion: @escaping CompletionType<Int>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestPinThread(request, completion, uniqueIdResult)
    }

    /// UNPin a thread.
    /// - Parameters:
    ///   - request: The request with a thread id.
    ///   - completion: Response of unpin thread.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func unpinThread(_ request: GeneralSubjectIdRequest, completion: @escaping CompletionType<Int>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestUnPinThread(request, completion, uniqueIdResult)
    }

    /// Create a thread.
    /// - Parameters:
    ///   - request: The request of create a thread.
    ///   - completion: Response to create thread which contains a ``Conversation`` that includes threadId and other properties.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func createThread(_ request: CreateThreadRequest, completion: @escaping CompletionType<Conversation>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestCreateThread(request, completion, uniqueIdResult)
    }

    /// Create thread with a message.
    /// - Parameters:
    ///   - request: The request with a message and threadId.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    ///   - onSent: Call when message is snet.
    ///   - onDelivery:  Call when message deliverd but not seen yet.
    ///   - onSeen: Call when message is seen.
    ///   - completion: Response of request and created thread.
    public func createThreadWithMessage(_ request: CreateThreadWithMessage,
                                        uniqueIdResult: UniqueIdResultType? = nil,
                                        onSent _: OnSentType? = nil,
                                        onDelivery _: OnDeliveryType? = nil,
                                        onSeen _: OnSentType? = nil,
                                        completion: @escaping CompletionType<Conversation>)
    {
        requestCreateThreadWithMessage(request, completion, uniqueIdResult)
    }

    /// Create thread and send a file message.
    /// - Parameters:
    ///   - request: Request of craete thread.
    ///   - textMessage: Text message.
    ///   - uploadFile: File request.
    ///   - uploadProgress: Track the progress of uploading.
    ///   - onSent: Call when message is snet.
    ///   - onSeen: Call when message is seen.
    ///   - onDeliver: Call when message deliverd but not seen yet.
    ///   - createThreadCompletion: Call when the thread is created, and it's called before uploading gets completed
    ///   - uploadUniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    ///   - messageUniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func createThreadWithFileMessage(_ request: CreateThreadRequest,
                                            textMessage: SendTextMessageRequest,
                                            uploadFile: UploadFileRequest,
                                            uploadProgress: UploadFileProgressType? = nil,
                                            onSent: OnSentType? = nil,
                                            onSeen: OnSeenType? = nil,
                                            onDeliver: OnDeliveryType? = nil,
                                            createThreadCompletion: CompletionType<Conversation>? = nil,
                                            uploadUniqueIdResult: UniqueIdResultType? = nil,
                                            messageUniqueIdResult: UniqueIdResultType? = nil)
    {
        requestCreateThreadWithFileMessage(request, textMessage, uploadFile, uploadProgress, onSent, onSeen, onDeliver, createThreadCompletion, uploadUniqueIdResult, messageUniqueIdResult)
    }

    /// Add participant to a thread.
    /// - Parameters:
    ///   - request: Fill in the appropriate initializer.
    ///   - completion: Reponse of request.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func addParticipant(_ request: AddParticipantRequest, completion: @escaping CompletionType<Conversation>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestAddParticipant(request, completion, uniqueIdResult)
    }

    /// Remove participants from a thread.
    /// - Parameters:
    ///   - request: List of participants id and threadId.
    ///   - completion: Result of deleted participants.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func removeParticipants(_ request: RemoveParticipantsRequest, completion: @escaping CompletionType<[Participant]>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestRemoveParticipants(request, completion, uniqueIdResult)
    }

    /// Join to a public thread.
    /// - Parameters:
    ///   - request: Thread name of public thread.
    ///   - completion: Detail of public thread as a ``Conversation`` object.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func joinThread(_ request: JoinPublicThreadRequest, completion: @escaping CompletionType<Conversation>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestJoinThread(request, completion, uniqueIdResult)
    }

    /// Close a thread.
    ///
    /// With the closing, a thread participants of it can't send a message to it.
    /// - Parameters:
    ///   - request: Thread Id of the thread you want to be closed.
    ///   - completion: The id of the thread which closed.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func closeThread(_ request: GeneralSubjectIdRequest, completion: @escaping CompletionType<Int>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestCloseThread(request, completion, uniqueIdResult)
    }

    /// Mark a thread as an spam
    ///
    /// A spammed thread can't send a message anymore.
    /// - Parameters:
    ///   - request: Request to spam a thread.
    ///   - completion: Response of request.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func spamPvThread(_ request: GeneralSubjectIdRequest, completion: @escaping CompletionType<BlockedContact>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestSpamThread(request, completion, uniqueIdResult)
    }

    /// Update details of a thread.
    /// - Parameters:
    ///   - request: The request might contain an image, title, description, and a threadId.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    ///   - uploadProgress: Upload progrees if you update image of the thread.
    ///   - completion: Response of update.
    public func updateThreadInfo(_ request: UpdateThreadInfoRequest, uniqueIdResult: UniqueIdResultType? = nil, uploadProgress: @escaping UploadFileProgressType, completion: @escaping CompletionType<Conversation>) {
        requestUpdateThreadInfo(request, uploadProgress, completion, uniqueIdResult)
    }

    /// Leave a thread.
    /// - Parameters:
    ///   - request: The threadId if the thread with option to clear it's content.
    ///   - completion: The response of the left thread..
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func leaveThread(_ request: LeaveThreadRequest, completion: @escaping CompletionType<User>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestLeaveThread(request, completion, uniqueIdResult)
    }

    /// Delete a thread if you are admin in this thread.
    /// - Parameters:
    ///   - request: The request that contains thread id.
    ///   - completion: Result of request.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func deleteThread(_ request: GeneralSubjectIdRequest, completion: @escaping CompletionType<Int>, uniqueIdResult _: UniqueIdResultType? = nil) {
        requestDeleteThread(request, completion)
    }

    /// Leave a thrad with replaceing admin.
    /// - Parameters:
    ///   - request: The request that contains threadId and participantId of new admin.
    ///   - completion: Result of request.
    ///   - newAdminCompletion: Result of new admin.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func leaveThreadSaftly(_ request: SafeLeaveThreadRequest, completion: @escaping CompletionType<User>, newAdminCompletion: CompletionType<[UserRole]>? = nil, uniqueIdResult: UniqueIdResultType? = nil) {
        requestChangeAdminAndLeaveThread(request, completion, newAdminCompletion, uniqueIdResult)
    }

    /// Get thread participants.
    /// - Parameters:
    ///   - request: The request that contain threadId and count and offset.
    ///   - completion: Pagination list of participants.
    ///   - cacheResponse: Cache response of participants inside a thread.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func getThreadParticipants(_ request: ThreadParticipantsRequest, completion: @escaping CompletionType<[Participant]>, cacheResponse: CacheResponseType<[Participant]>? = nil, uniqueIdResult: UniqueIdResultType? = nil) {
        requestThreadParticipants(request, completion, cacheResponse, uniqueIdResult)
    }

    /// Get thread participants.
    ///
    /// It's the same ``Chat/getThreadParticipants(_:completion:cacheResponse:uniqueIdResult:)`` only return admins.
    /// - Parameters:
    ///   - request: The request that contain threadId and count and offset.
    ///   - completion: Pagination list of participants.
    ///   - cacheResponse: Cache response of participants inside a thread.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func getThreadAdmins(_ request: ThreadParticipantsRequest, completion: @escaping CompletionType<[Participant]>, cacheResponse: CacheResponseType<[Participant]>? = nil, uniqueIdResult: UniqueIdResultType? = nil) {
        request.admin = true
        requestThreadParticipants(request, completion, cacheResponse, uniqueIdResult)
    }

    /// Change a type of thread.
    /// - Parameters:
    ///   - request: The request that contains threadId and type of desierd thread.
    ///   - completion: Response of the request.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func changeThreadType(_ request: ChangeThreadTypeRequest, completion: @escaping CompletionType<Conversation>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestChangeThreadType(request, completion, uniqueIdResult)
    }

    /// Create Bot.
    /// - Parameters:
    ///   - request: The request that contains the name bot.
    ///   - completion: The responser of the request.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func createBot(_ request: CreateBotRequest, completion: @escaping CompletionType<Bot>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestCreateBot(request, completion, uniqueIdResult)
    }

    /// Add commands to a bot.
    /// - Parameters:
    ///   - request: The request that contains the name bot and list of commands.
    ///   - completion: The responser of the request.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func addBotCommand(_ request: AddBotCommandRequest, completion: @escaping CompletionType<BotInfo>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestAddBotCommand(request, completion, uniqueIdResult)
    }

    /// Remove commands from a bot.
    /// - Parameters:
    ///   - request: The request that contains the name bot and list of commands.
    ///   - completion: The responser of the request.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func removeBotCommand(_ request: RemoveBotCommandRequest, completion: @escaping CompletionType<BotInfo>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestRemoveBotCommand(request, completion, uniqueIdResult)
    }

    /// Get all user bots.
    /// - Parameters:
    ///   - request: Request if want to have different uniqueId.
    ///   - completion: List of user bots.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func getUserBots(_ request: GetUserBotsRequest, completion: @escaping CompletionType<[BotInfo]>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestBots(request, completion, uniqueIdResult)
    }

    /// Start a bot.
    /// - Parameters:
    ///   - request: The request with threadName and a threadId.
    ///   - completion: Name of a bot if it starts successfully.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func startBot(_ request: StartStopBotRequest, completion: @escaping CompletionType<String>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestStartBot(request, completion, uniqueIdResult)
    }

    /// Stop a bot.
    /// - Parameters:
    ///   - request: The request with threadName and a threadId.
    ///   - completion: Name of a bot if it stopped successfully.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func stopBot(_ request: StartStopBotRequest, completion: @escaping CompletionType<String>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestStopBot(request, completion, uniqueIdResult)
    }

    /// Getting current user details.
    /// - Parameters:
    ///   - request: The request:
    ///   - completion: Response of the request.
    ///   - cacheResponse: cache response for the current user.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func getUserInfo(_ request: UserInfoRequest, completion: @escaping CompletionType<User>, cacheResponse: CacheResponseType<User>? = nil, uniqueIdResult: UniqueIdResultType? = nil) {
        requestUserInfo(request, completion, cacheResponse, uniqueIdResult)
    }

    /// Update current user details.
    /// - Parameters:
    ///   - request: The request that contains bio and metadata.
    ///   - completion: New profile response.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func setProfile(_ request: UpdateChatProfile, completion: @escaping CompletionType<Profile>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestSetProfile(request, completion, uniqueIdResult)
    }

    /// <#Description#>
    /// - Parameter request: <#request description#>
    public func sendStatusPing(_ request: SendStatusPingRequest) {
        requestSendStatusPing(request)
    }

    /// List of Tags.
    /// - Parameters:
    ///   - uniqueId: The uniqueId of request if you want to set a specific one.
    ///   - completion: List of tags.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func tagList(_ uniqueId: String? = nil, completion: @escaping CompletionType<[Tag]>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestTags(uniqueId, completion, uniqueIdResult)
    }

    /// Create a new tag.
    /// - Parameters:
    ///   - request: The name of the tag.
    ///   - completion: Response of the request if tag added successfully.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func createTag(_ request: CreateTagRequest, completion: @escaping CompletionType<Tag>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestCreateTag(request, completion, uniqueIdResult)
    }

    /// Edit the tag name.
    /// - Parameters:
    ///   - request: The id of the tag and new name of the tag.
    ///   - completion: Response of the request if tag edited successfully.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func editTag(_ request: EditTagRequest, completion: @escaping CompletionType<Tag>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestEditTag(request, completion, uniqueIdResult)
    }

    /// Delete a tag.
    /// - Parameters:
    ///   - request: The id of tag.
    ///   - completion: Response of the request if tag deleted successfully.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func deleteTag(_ request: DeleteTagRequest, completion: @escaping CompletionType<Tag>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestDeleteTag(request, completion, uniqueIdResult)
    }

    /// Add threads to a tag.
    /// - Parameters:
    ///   - request: The tag id and list of threads id.
    ///   - completion: The response of the request which contains list of tagParticipants added.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func addTagParticipants(_ request: AddTagParticipantsRequest, completion: @escaping CompletionType<[TagParticipant]>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestAddTagParticipants(request, completion, uniqueIdResult)
    }

    /// Remove tag participants from a tag.
    /// - Parameters:
    ///   - request: The tag id and the list of tag participants id.
    ///   - completion: List of removed tag participants.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func removeTagParticipants(_ request: RemoveTagParticipantsRequest, completion: @escaping CompletionType<[TagParticipant]>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestRemoveTagParticipants(request, completion, uniqueIdResult)
    }

    /// Get the list of tag participants.
    /// - Parameters:
    ///   - request: The tag id.
    ///   - completion: List of tag participants.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func getTagParticipants(_ request: GetTagParticipantsRequest, completion: @escaping CompletionType<[TagParticipant]>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestTagParticipants(request, completion, uniqueIdResult)
    }

    /// Send a plain text message to a thread.
    /// - Parameters:
    ///   - request: The request that contains text message and id of the thread.
    ///   - uniqueIdresult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    ///   - onSent: Is called when a message sent successfully.
    ///   - onSeen: Is called when a message, have seen by a participant successfully.
    ///   - onDeliver: Is called when a message, have delivered to a participant successfully.
    public func sendTextMessage(_ request: SendTextMessageRequest, uniqueIdresult: UniqueIdResultType? = nil, onSent: OnSentType? = nil, onSeen: OnSeenType? = nil, onDeliver: OnDeliveryType? = nil) {
        requestSendMessage(request, onSent, onSeen, onDeliver, uniqueIdresult)
    }

    /// Edit a message.
    /// - Parameters:
    ///   - request: The request that contains threadId and messageId and new text for the message you want to edit.
    ///   - completion: The result of edited message.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func editMessage(_ request: EditMessageRequest, completion: CompletionType<Message>? = nil, uniqueIdResult: UniqueIdResultType? = nil) {
        requestEditMessage(request, completion, uniqueIdResult)
    }

    /// Reply to a message.
    /// - Parameters:
    ///   - request: The request contains the id of the message you want to reply to, and id of the thread, and a text message.
    ///   - uniqueIdresult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    ///   - onSent: Is called when a message sent successfully.
    ///   - onSeen: Is called when a message, have seen by a participant successfully.
    ///   - onDeliver: Is called when a message, have delivered to a participant successfully.
    public func replyMessage(_ request: ReplyMessageRequest, uniqueIdresult: UniqueIdResultType? = nil, onSent: OnSentType? = nil, onSeen: OnSeenType? = nil, onDeliver: OnDeliveryType? = nil) {
        requestSendMessage(request, onSent, onSeen, onDeliver, uniqueIdresult)
    }

    /// Send a location.
    /// - Parameters:
    ///   - request: The request that gets a threadId and a location and a ``Conversation/userGroupHash``.
    ///   - uploadProgress: Progress of uploading an image of the location to the thread.
    ///   - downloadProgress: Download progess of image.
    ///   - onSent: Is called when a message sent successfully.
    ///   - onSeen: Is called when a message, have seen by a participant successfully.
    ///   - onDeliver: Is called when a message, have delivered to a participant successfully.
    ///   - uploadUniqueIdResult: Unique id of upload file you could cancel an upload if you need it.
    ///   - messageUniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func sendLocationMessage(_ request: LocationMessageRequest,
                                    uploadProgress: UploadFileProgressType? = nil,
                                    downloadProgress: DownloadProgressType? = nil,
                                    onSent: OnSentType? = nil,
                                    onSeen: OnSeenType? = nil,
                                    onDeliver: OnDeliveryType? = nil,
                                    uploadUniqueIdResult: UniqueIdResultType? = nil,
                                    messageUniqueIdResult: UniqueIdResultType? = nil)
    {
        requestSendLocationMessage(request, downloadProgress, uploadProgress, onSent, onSeen, onDeliver, uploadUniqueIdResult, messageUniqueIdResult)
    }

    /// Forwrad messages to a thread.
    /// - Parameters:
    ///   - request: The request that contains messageId list and a destination threadId.
    ///   - onSent: Is called when a message sent successfully.
    ///   - onSeen: Is called when a message, have seen by a participant successfully.
    ///   - onDeliver: Is called when a message, have delivered to a participant successfully.
    ///   - uniqueIdsResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func forwardMessages(_ request: ForwardMessageRequest, onSent: OnSentType? = nil, onSeen: OnSeenType? = nil, onDeliver: OnDeliveryType? = nil, uniqueIdsResult: UniqueIdsResultType? = nil) {
        requestForwardMessage(request, onSent, onSeen, onDeliver, uniqueIdsResult)
    }

    /// Get list of messages inside a thread.
    /// - Parameters:
    ///   - request: The threadId and other filter properties.
    ///   - completion: The response which can contains llist of messages.
    ///   - cacheResponse: The cache response.
    ///   - textMessageNotSentRequests: A list of messages that failed to sent.
    ///   - editMessageNotSentRequests: A list of edit messages that failed to sent.
    ///   - forwardMessageNotSentRequests: A list of forward messages that failed to sent.
    ///   - fileMessageNotSentRequests: A list of file messages that failed to sent.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func getHistory(_ request: GetHistoryRequest,
                           completion: @escaping CompletionType<[Message]>,
                           cacheResponse: CacheResponseType<[Message]>? = nil,
                           textMessageNotSentRequests: CompletionTypeNoneDecodeable<[SendTextMessageRequest]>? = nil,
                           editMessageNotSentRequests: CompletionTypeNoneDecodeable<[EditMessageRequest]>? = nil,
                           forwardMessageNotSentRequests: CompletionTypeNoneDecodeable<[ForwardMessageRequest]>? = nil,
                           fileMessageNotSentRequests: CompletionTypeNoneDecodeable<[(UploadFileRequest, SendTextMessageRequest)]>? = nil,
                           uniqueIdResult: UniqueIdResultType? = nil)
    {
        requestGetHistory(request,
                          completion,
                          cacheResponse,
                          textMessageNotSentRequests,
                          editMessageNotSentRequests,
                          forwardMessageNotSentRequests,
                          fileMessageNotSentRequests,
                          uniqueIdResult)
    }

    /// Get list of messages with hashtags.
    /// - Parameters:
    ///   - request: A request that containst a threadId and hashtag name.
    ///   - completion: The response of messages.
    ///   - cacheResponse: The cache response.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func getHashtagList(_ request: GetHistoryRequest,
                               completion: @escaping CompletionType<[Message]>,
                               cacheResponse: CacheResponseType<[Message]>? = nil,
                               uniqueIdResult: UniqueIdResultType? = nil)
    {
        requestGetHistory(request, completion, cacheResponse, nil, nil, nil, nil, uniqueIdResult)
    }

    /// Pin a message inside a thread.
    /// - Parameters:
    ///   - request: The request that contains messageId.
    ///   - completion: The response of pinned thread.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func pinMessage(_ request: PinUnpinMessageRequest, completion: @escaping CompletionType<PinUnpinMessage>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestPinUnPinMessage(request, completion, uniqueIdResult)
    }

    /// UnPin a message inside a thread.
    /// - Parameters:
    ///   - request: The request that contains messageId.
    ///   - completion: The response of unpinned thread.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func unpinMessage(_ request: PinUnpinMessageRequest, completion: @escaping CompletionType<PinUnpinMessage>, uniqueIdResult: UniqueIdResultType? = nil) {
        request.chatMessageType = .unpinMessage
        requestPinUnPinMessage(request, completion, uniqueIdResult)
    }

    /// Clear all messages inside a thread for user.
    /// - Parameters:
    ///   - request: The request that  contains a threadId.
    ///   - completion: A threadId if the result was a success.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func clearHistory(_ request: GeneralSubjectIdRequest, completion: @escaping CompletionType<Int>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestClearHistory(request, completion, uniqueIdResult)
    }

    /// Delete a message if it's ``Message/deletable``.
    /// - Parameters:
    ///   - request: The delete request with a messageId.
    ///   - completion: The response of deleted message.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func deleteMessage(_ request: DeleteMessageRequest, completion: @escaping CompletionType<Message>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestDeleteMessage(request, completion, uniqueIdResult)
    }

    /// Delete multiple messages at once.
    /// - Parameters:
    ///   - request: The delete request with list of messagesId.
    ///   - completion: List of deleted messages.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func deleteMultipleMessages(_ request: BatchDeleteMessageRequest, completion: @escaping CompletionType<Message>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestBatchDeleteMessage(request, completion, uniqueIdResult)
    }

    /// Get the number of unread message count.
    /// - Parameters:
    ///   - request: The request can contain property to aggregate mute threads unread count.
    ///   - completion: The number of unread message count.
    ///   - cacheResponse: The number of unread message count in cache.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func allUnreadMessageCount(_ request: UnreadMessageCountRequest, completion: @escaping CompletionType<Int>, cacheResponse: CacheResponseType<Int>? = nil, uniqueIdResult: UniqueIdResultType? = nil) {
        requestUnredMessageCount(request, completion, cacheResponse, uniqueIdResult)
    }

    /// Get messages that you have mentioned in a thread.
    /// - Parameters:
    ///   - request: The request that contains a threadId.
    ///   - completion: The response contains a list of messages that you have mentioned.
    ///   - cacheResponse: The cache response of mentioned messages inside a thread.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func getMentions(_ request: MentionRequest, completion: @escaping CompletionType<[Message]>, cacheResponse: CacheResponseType<[Message]>? = nil, uniqueIdResult: UniqueIdResultType? = nil) {
        requestMentions(request, completion, cacheResponse, uniqueIdResult)
    }

    /// Retrieve the list of participants to who the message was delivered to them.
    /// - Parameters:
    ///   - request: The request that contains a message id.
    ///   - completion: List of participants.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func messageDeliveredToParticipants(_ request: MessageDeliveredUsersRequest, completion: @escaping CacheResponseType<[Participant]>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestMessagedeliveredToParticipnats(request, completion, uniqueIdResult)
    }

    /// Retrieve the list of participants to who have seen the message.
    /// - Parameters:
    ///   - request: The request that contains a message id.
    ///   - completion: List of participants.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func messageSeenByUsers(_ request: MessageSeenByUsersRequest, completion: @escaping CacheResponseType<[Participant]>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestMessageSeenByParticipants(request, completion, uniqueIdResult)
    }

    /// Tell the sender of a message that the message is delivered successfully.
    /// - Parameters:
    ///   - request: The request that contains a messageId.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    internal func deliver(_ request: MessageDeliverRequest, uniqueIdResult: UniqueIdResultType? = nil) {
        requestSendDeliverMessage(request, uniqueIdResult)
    }

    /// Send seen to participants of a thread that informs you have seen the message already.
    ///
    /// When you send seen the last seen messageId and unreadCount will be updated in cache behind the scene.
    /// - Parameters:
    ///   - request: The id of the message.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func seen(_ request: MessageSeenRequest, uniqueIdResult: UniqueIdResultType? = nil) {
        requestSendSeenMessage(request, uniqueIdResult)
    }

    /// Get the roles of the current user in a thread.
    /// - Parameters:
    ///   - request: A request that contains a threadId.
    ///   - completion: List of the roles of a user.
    ///   - cacheResponse: The cache response of roles.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func getCurrentUserRoles(_ request: GeneralSubjectIdRequest, completion: @escaping CompletionType<[Roles]>, cacheResponse: CacheResponseType<[Roles]>? = nil, uniqueIdResult: UniqueIdResultType? = nil) {
        requestCurrentUserRoles(request, completion, cacheResponse, uniqueIdResult)
    }

    /// Cancel a message send.
    /// - Parameters:
    ///   - request: The uniqueId of a message.
    ///   - completion: The result of cancelation.
    public func cancelMessage(_ request: CancelMessageRequest, completion: @escaping CompletionTypeNoneDecodeable<Bool>) {
        requestCancelMessage(request, completion)
    }

    /// Send a event to the participants of a thread that you are typing something.
    /// - Parameter threadId: The id of the thread.
    public func snedStartTyping(threadId: Int) {
        requestStartTyping(threadId)
    }

    /// Send user stop typing.
    public func sendStopTyping() {
        stopTyping()
    }

    /// Tell the server user has logged out.
    public func logOut() {
        requestLogout()
    }

    /// Notify some system actions such as upload a file, record a voice and e.g.
    /// - Parameter req: A request that contains the type of request and a threadId.
    public func sendSignalMessage(req: SendSignalMessageRequest) {
        prepareToSendAsync(req: req)
    }

    /// Downloading or getting a file from the Server / Cache.
    /// - Parameters:
    ///   - req: The request that contains Hashcode of file and a config to download from server or use cache.
    ///   - downloadProgress: The progress of download.
    ///   - completion: The completion block tells you whether the file was successfully downloaded or not.
    ///   - cacheResponse: The cache version of file.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func getFile(req: FileRequest,
                        downloadProgress: @escaping DownloadProgressType,
                        completion: @escaping DownloadFileCompletionType,
                        cacheResponse: @escaping DownloadFileCompletionType,
                        uniqueIdResult: UniqueIdResultType? = nil)
    {
        requestDownloadFile(req, uniqueIdResult, downloadProgress, completion, cacheResponse)
    }

    /// Downloading or getting an image from the Server / Cache.
    /// - Parameters:
    ///   - req: The request that contains Hashcode of image and a config to download from server or use cache.
    ///   - downloadProgress: The progress of download.
    ///   - completion: The completion block tells you whether the image was successfully downloaded or not.
    ///   - cacheResponse: The cache version of image.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func getImage(req: ImageRequest,
                         downloadProgress: @escaping DownloadProgressType,
                         completion: @escaping DownloadImageCompletionType,
                         cacheResponse: @escaping DownloadImageCompletionType,
                         uniqueIdResult: UniqueIdResultType? = nil)
    {
        requestDownloadImage(req, uniqueIdResult, downloadProgress, completion, cacheResponse)
    }

    /// Upload a file.
    /// - Parameters:
    ///   - req: The request that contains the data of file and other file properties.
    ///   - uploadUniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    ///   - uploadProgress: The progress of uploading file.
    ///   - uploadCompletion: The result shows whether the upload was successful or not.
    public func uploadFile(req: UploadFileRequest,
                           uploadUniqueIdResult: UniqueIdResultType? = nil,
                           uploadProgress: UploadFileProgressType? = nil,
                           uploadCompletion: UploadCompletionType? = nil)
    {
        requestUploadFile(req, uploadCompletion, uploadProgress, uploadUniqueIdResult)
    }

    /// Upload an image.
    /// - Parameters:
    ///   - req: The request that contains the data of an image and other image properties.
    ///   - uploadUniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    ///   - uploadProgress: The progress of uploading the image.
    ///   - uploadCompletion: The result shows whether the upload was successful or not.
    public func uploadImage(req: UploadImageRequest,
                            uploadUniqueIdResult: UniqueIdResultType? = nil,
                            uploadProgress: UploadFileProgressType? = nil,
                            uploadCompletion: UploadCompletionType? = nil)
    {
        requestUploadImage(req, uploadCompletion, uploadProgress, uploadUniqueIdResult)
    }

    /// Reply to a mesaage inside a thread with a file.
    /// - Parameters:
    ///   - replyMessage: The request that contains the threadId and a text message an id of an message you want to reply.
    ///   - uploadFile: The request that contains the data of file and other file properties
    ///   - uploadProgress: The progress of uploading file.
    ///   - onSent: Is called when a message sent successfully.
    ///   - onSeen: Is called when a message, have seen by a participant successfully.
    ///   - onDeliver: Is called when a message, have delivered to a participant successfully.
    ///   - uploadUniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    ///   - messageUniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func replyFileMessage(replyMessage: ReplyMessageRequest,
                                 uploadFile: UploadFileRequest,
                                 uploadProgress: UploadFileProgressType? = nil,
                                 onSent: OnSentType? = nil,
                                 onSeen: OnSeenType? = nil,
                                 onDeliver: OnDeliveryType? = nil,
                                 uploadUniqueIdResult: UniqueIdResultType? = nil,
                                 messageUniqueIdResult: UniqueIdResultType? = nil)
    {
        sendFileMessage(textMessage: replyMessage,
                        uploadFile: uploadFile,
                        uploadProgress: uploadProgress,
                        onSent: onSent,
                        onSeen: onSeen,
                        onDeliver: onDeliver,
                        uploadUniqueIdResult: uploadUniqueIdResult,
                        messageUniqueIdResult: messageUniqueIdResult)
    }

    /// Send a file message.
    /// - Parameters:
    ///   - textMessage: A text message with a threadId.
    ///   - uploadFile: The progress of uploading file.
    ///   - uploadProgress: The progress of uploading file.
    ///   - onSent: Is called when a message sent successfully.
    ///   - onSeen: Is called when a message, have seen by a participant successfully.
    ///   - onDeliver: Is called when a message, have delivered to a participant successfully.
    ///   - uploadUniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    ///   - messageUniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func sendFileMessage(textMessage: SendTextMessageRequest,
                                uploadFile: UploadFileRequest,
                                uploadProgress: UploadFileProgressType? = nil,
                                onSent: OnSentType? = nil,
                                onSeen: OnSeenType? = nil,
                                onDeliver: OnDeliveryType? = nil,
                                uploadUniqueIdResult: UniqueIdResultType? = nil,
                                messageUniqueIdResult: UniqueIdResultType? = nil)
    {
        if let uploadRequest = uploadFile as? UploadImageRequest {
            requestSendImageTextMessage(textMessage, uploadRequest, onSent, onSeen, onDeliver, uploadProgress, uploadUniqueIdResult, messageUniqueIdResult)
            return
        }
        requestSendFileTextMessage(textMessage, uploadFile, onSent, onSeen, onDeliver, uploadProgress, uploadUniqueIdResult, messageUniqueIdResult)
    }

    /// Manage a uploading file or an image.
    /// - Parameters:
    ///   - uniqueId: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    ///   - action: Action to pause, resume or cancel.
    ///   - isImage: Distinguish between file or image.
    ///   - completion: The result of aciton.
    public func manageUpload(uniqueId: String, action: DownloaUploadAction, completion: ((String, Bool) -> Void)? = nil) {
        requestManageUpload(uniqueId, action, completion)
    }

    /// Manage a downloading file or an image.
    /// - Parameters:
    ///   - uniqueId: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    ///   - action: Action to pause, resume or cancel.
    ///   - isImage: Distinguish between file or image.
    ///   - completion: The result of aciton.
    public func manageDownload(uniqueId: String, action: DownloaUploadAction, completion: ((String, Bool) -> Void)? = nil) {
        requestManageDownload(uniqueId, action, completion)
    }

    /// Register a participant as an assistant.
    /// - Parameters:
    ///   - request: The request that contains list of assistants.
    ///   - completion: A list of assistant that added for the user.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func registerAssistat(_ request: RegisterAssistantRequest, completion: @escaping CompletionType<[Assistant]>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestRegisterAssistant(request, completion, uniqueIdResult)
    }

    /// Deactivate assistants.
    /// - Parameters:
    ///   - request: A request that contains a list of activated assistants.
    ///   - completion: The result of deactivated assistants.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func deactiveAssistant(_ request: DeactiveAssistantRequest, completion: @escaping CompletionType<[Assistant]>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestDeactiveAssistant(request, completion, uniqueIdResult)
    }

    /// Get list of assistants for user.
    /// - Parameters:
    ///   - request: A request with a contact type and offset, count.
    ///   - completion: The list of assistants.
    ///   - cacheResponse: The cache response of list of assistants.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func getAssistats(_ request: AssistantsRequest, completion: @escaping CompletionType<[Assistant]>, cacheResponse: CompletionType<[Assistant]>? = nil, uniqueIdResult: UniqueIdResultType? = nil) {
        requestAssistants(request, completion, cacheResponse, uniqueIdResult)
    }

    /// Get a history of assitant actions.
    /// - Parameters:
    ///   - completion: The list of actions of an assistants.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func getAssistatsHistory(_ completion: @escaping CompletionType<[AssistantAction]>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestAssitantHistory(completion, uniqueIdResult)
    }

    /// Get list of blocked assistants.
    /// - Parameters:
    ///   - request: A request that contains an offset and count.
    ///   - completion: List of blocked assistants.
    ///   - cacheResponse: The cached version of blocked assistants.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func getBlockedAssistants(_ request: BlockedAssistantsRequest, _ completion: @escaping CompletionType<[Assistant]>, cacheResponse: CacheResponseType<[Assistant]>? = nil, uniqueIdResult: UniqueIdResultType? = nil) {
        requestGetBlockedAssistants(request, completion, cacheResponse, uniqueIdResult)
    }

    /// Block assistants.
    /// - Parameters:
    ///   - request: A list of assistants you want to block them.
    ///   - completion: List of blocked assistants.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func blockAssistants(_ request: BlockUnblockAssistantRequest, _ completion: @escaping CompletionType<[Assistant]>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestBlockAssistant(request, completion, uniqueIdResult)
    }

    /// UNBlock assistants.
    /// - Parameters:
    ///   - request: A list of assistants you want to unblock them.
    ///   - completion: List of unblocked assistants.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func unblockAssistants(_ request: BlockUnblockAssistantRequest, _ completion: @escaping CompletionType<[Assistant]>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestUnBlockAssistant(request, completion, uniqueIdResult)
    }

    /// Set a set of roles to a participant of a thread.
    /// - Parameters:
    ///   - request: A request that contains a set of roles and a threadId.
    ///   - completion: List of applied roles for a participant.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func setRoles(_ request: RolesRequest, _ completion: @escaping CompletionType<[UserRole]>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestSetRoles(request, completion, uniqueIdResult)
    }

    /// Remove set of roles from a participant.
    /// - Parameters:
    ///   - request: A request that contains a set of roles and a threadId.
    ///   - completion: List of removed roles for a participant.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func removeRoles(_ request: RolesRequest, _ completion: @escaping CompletionType<[UserRole]>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestRemoveRole(request, completion, uniqueIdResult)
    }

    /// Set a participant auditor access roles.
    /// - Parameters:
    ///   - request: A request that contains a threadId and roles of user with userId.
    ///   - completion: List of roles that applied for the users.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func setAuditor(_ request: AuditorRequest, _ completion: @escaping CompletionType<[UserRole]>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestSetRoles(request, completion, uniqueIdResult)
    }

    /// Remove a participant auditor access roles.
    /// - Parameters:
    ///   - request: A request that contains a threadId and roles of user with userId.
    ///   - completion: List of roles that removed roles for the users.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func removeAuditor(_ request: AuditorRequest, _ completion: @escaping CompletionType<[UserRole]>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestRemoveRole(request, completion, uniqueIdResult)
    }

    /// A list of mutual groups with a user.
    /// - Parameters:
    ///   - request: A request that contains a detail of a user invtee.
    ///   - completion: List of threads that are mutual between the current user and desired user.
    ///   - cacheResponse: The cached version of mutual groups.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func mutualGroups(_ request: MutualGroupsRequest, _ completion: @escaping CompletionType<[Conversation]>, cacheResponse: CacheResponseType<[Conversation]>? = nil, uniqueIdResult: UniqueIdResultType? = nil) {
        requestMutualGroups(request, completion, cacheResponse, uniqueIdResult)
    }

    /// Every time you call this function old export file for the thread will be deleted and replaced with a new one. To manages your storage be cautious about removing the file whenever you don't need this file.
    /// This function can only export 10000 messages.
    /// - Parameters:
    ///   - request: A request that contains threadId and other filters to export.
    ///   - localIdentifire: The locals to output.
    ///   - completion: A file url of a csv file.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func exportChat(_ request: GetHistoryRequest, _ completion: @escaping CompletionTypeNoneDecodeable<URL>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestExportMessages(request, completion, uniqueIdResult)
    }

    /// Archive a thread.
    /// - Parameters:
    ///   - request: A request that contains the threadId.
    ///   - completion: A response which contain the threadId of archived thread.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func archiveThread(_ request: GeneralSubjectIdRequest, _ completion: @escaping CompletionType<Int>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestArchiveThread(request, completion, uniqueIdResult)
    }

    /// Unarchive a thread.
    /// - Parameters:
    ///   - request: A request that contains the threadId.
    ///   - completion: A response which contain the threadId of unarchived thread.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func unarchiveThread(_ request: GeneralSubjectIdRequest, _ completion: @escaping CompletionType<Int>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestUnArchiveThread(request, completion, uniqueIdResult)
    }

    // MARK: START Call REGION

    /// Start request a call.
    /// - Parameters:
    ///   - request: The request to how to start the call as an example start call with a threadId.
    ///   - completion: A response that tell you if the call is created and contains a callId and more.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func requestCall(_ request: StartCallRequest, _ completion: @escaping CompletionType<CreateCall>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestStartCall(request, completion, uniqueIdResult)
    }

    /// Start a group call with list of people or a threadId.
    /// - Parameters:
    ///   - request: A request that contains a list of people or a threadId.
    ///   - completion: A response that tell you if the call is created and contains a callId and more.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func requestGroupCall(_ request: StartCallRequest, _ completion: @escaping CompletionType<CreateCall>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestStartGroupCall(request, completion, uniqueIdResult)
    }

    /// An internal method when a call has arrived.
    /// - Parameter request: A calId.
    internal func callReceived(_ request: GeneralSubjectIdRequest) {
        requestReceivedCall(request)
    }

    /// To terminate a call.
    /// - Parameters:
    ///   - request: A request with a callId to finish the current call.
    ///   - completion: A callId that shows a call has terminated properly.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func endCall(_ request: GeneralSubjectIdRequest, _ completion: @escaping CompletionType<Int>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestEndCall(request, completion, uniqueIdResult)
    }

    /// Add a new participant to a thread during the call.
    /// - Parameters:
    ///   - request: A List of people with userNames or contactIds beside a callId.
    ///   - completion: A list of participants has been added to the current call.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func addCallPartcipant(_ request: AddCallParticipantsRequest, _ completion: @escaping CompletionType<[CallParticipant]>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestAddCallParticipant(request, completion, uniqueIdResult)
    }

    /// Remove a participant from a call if you have access.
    /// - Parameters:
    ///   - request: The request that contains a callId and llist of user to remove from a call.
    ///   - completion: List of removed participants from a call.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func removeCallPartcipant(_ request: RemoveCallParticipantsRequest, _ completion: @escaping CompletionType<[CallParticipant]>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestRemoveCallParticipant(request, completion, uniqueIdResult)
    }

    /// Accept a received call.
    /// - Parameters:
    ///   - request: The request that contains a callId and how do you want to answer the call as an example with audio or video.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func acceptCall(_ request: AcceptCallRequest, uniqueIdResult: UniqueIdResultType? = nil) {
        requestAcceptCall(request, uniqueIdResult)
    }

    /// The cancelation of a call when nobody answer the call or somthing different happen.
    /// - Parameters:
    ///   - request: A call that you want to cancel a call.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func cancelCall(_ request: CancelCallRequest, uniqueIdResult: UniqueIdResultType? = nil) {
        requestCancelCall(request, uniqueIdResult)
    }

    /// Turn on the camera during the conversation.
    /// - Parameters:
    ///   - request: The callId that you want to turn the camera on.
    ///   - completion: List of call participants that change during the request.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func turnOnVideoCall(_ request: GeneralSubjectIdRequest, _ completion: CompletionType<[CallParticipant]>? = nil, uniqueIdResult: UniqueIdResultType? = nil) {
        requestTurnOnVideoCall(request, completion, uniqueIdResult)
    }

    /// Turn off the camera during the conversation.
    /// - Parameters:
    ///   - request: The callId that you want to turn the camera off.
    ///   - completion: List of call participants that change during the request.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func turnOffVideoCall(_ request: GeneralSubjectIdRequest, _ completion: CompletionType<[CallParticipant]>? = nil, uniqueIdResult: UniqueIdResultType? = nil) {
        requestTurnOffVideoCall(request, completion, uniqueIdResult)
    }

    /// Mute the voice during the conversation.
    /// - Parameters:
    ///   - request: The callId that you want to turn the microphone off.
    ///   - completion: List of call participants that change during the request.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func muteCall(_ request: MuteCallRequest, _ completion: CompletionType<[CallParticipant]>? = nil, uniqueIdResult: UniqueIdResultType? = nil) {
        requestMuteCall(request, completion, uniqueIdResult)
    }

    /// UNMute the voice during the conversation.
    /// - Parameters:
    ///   - request: The callId that you want to turn the microphone on.
    ///   - completion: List of call participants that change during the request.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func unmuteCall(_ request: UNMuteCallRequest, _ completion: CompletionType<[CallParticipant]>? = nil, uniqueIdResult: UniqueIdResultType? = nil) {
        requestUNMuteCall(request, completion, uniqueIdResult)
    }

    /// Terminate the call completely for all the participants at once if you have access to it.
    /// - Parameters:
    ///   - request: The callId of the call to terminate.
    ///   - completion: List of call participants that change during the request.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func terminateCall(_ request: GeneralSubjectIdRequest, _ completion: CompletionType<[CallParticipant]>? = nil, uniqueIdResult: UniqueIdResultType? = nil) {
        requestTerminateCall(request, completion, uniqueIdResult)
    }

    /// List of active call participants during the call.
    /// - Parameters:
    ///   - request: The callId of the call.
    ///   - completion: List of call participants that change during the request.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func activeCallParticipants(_ request: GeneralSubjectIdRequest, _ completion: CompletionType<[CallParticipant]>? = nil, uniqueIdResult: UniqueIdResultType? = nil) {
        requestActiveCallParticipants(request, completion, uniqueIdResult)
    }

    /// A request to start recording a call.
    /// - Parameters:
    ///   - request: The callId of the call.
    ///   - completion: A participant that has started recording which is yourself.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func startRecording(_ request: GeneralSubjectIdRequest, _ completion: @escaping CompletionType<Participant>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestStartRecording(request, completion, uniqueIdResult)
    }

    /// A request to stop recording a call.
    /// - Parameters:
    ///   - request: The callId of the call.
    ///   - completion: A participant that has stopped recording which is yourself.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func stopRecording(_ request: GeneralSubjectIdRequest, _ completion: @escaping CompletionType<Participant>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestStopRecording(request, completion, uniqueIdResult)
    }

    /// List of the call history.
    /// - Parameters:
    ///   - request: The request that contains offset and count and some other filters.
    ///   - completion: List of calls.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func callsHistory(_ request: CallsHistoryRequest, _ completion: @escaping CompletionType<[Call]>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestCallsHistory(request, completion, uniqueIdResult)
    }

    /// A request that shows some errors has happened on the client side during the call for example maybe the user doesn't have access to the camera when trying to turn it on.
    /// - Parameters:
    ///   - request: The code of the error and a callId.
    ///   - completion: Shows the request has successfully arrived.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func sendCallClientError(_ request: CallClientErrorRequest, _ completion: @escaping CompletionType<CallError>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestSendCallError(request, completion, uniqueIdResult)
    }

    /// A list of calls that is currnetly is running and you could join to them.
    /// - Parameters:
    ///   - request: List of threads that you are in and more filters.
    ///   - completion: List of joinable calls.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func getCallsToJoin(_ request: GetJoinCallsRequest, _ completion: @escaping CompletionType<[Call]>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestJoinCall(request, completion, uniqueIdResult)
    }

    /// To renew  a call you could start request it by this method.
    /// - Parameters:
    ///   - request: The callId and list of the participants.
    ///   - completion: A created call with details.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func renewCallRequest(_ request: RenewCallRequest, _ completion: @escaping CompletionType<CreateCall>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestRenewCall(request, completion, uniqueIdResult)
    }

    /// To get the status of the call and participants after a disconnect or when you need it.
    /// - Parameters:
    ///   - request: The callId.
    ///   - completion: A created call with details.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func callInquery(_ request: GeneralSubjectIdRequest, _ completion: @escaping CompletionType<[CallParticipant]>, uniqueIdResult: UniqueIdResultType? = nil) {
        requestCallInquiry(request, completion, uniqueIdResult)
    }

    /// Send a sticker during the call..
    /// - Parameters:
    ///   - request: The callId and a sticker.
    ///   - completion: Response of the send.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func sendCallSticker(_ request: CallStickerRequest, _ completion: CompletionType<StickerResponse>? = nil, uniqueIdResult: UniqueIdResultType? = nil) {
        requestCallSticker(request, completion, uniqueIdResult)
    }

    // MARK: END Call RGION

    func prepareToSendAsync<T: Decodable>(
        req: ChatSendable,
        uniqueIdResult: UniqueIdResultType? = nil,
        completion: CompletionType<T>? = nil,
        onSent: OnSentType? = nil,
        onDelivered: OnDeliveryType? = nil,
        onSeen: OnSeenType? = nil
    ) {
        callbacksManager.addCallback(uniqueId: req.uniqueId, requesType: req.chatMessageType, callback: completion, onSent: onSent, onDelivered: onDelivered, onSeen: onSeen)
        uniqueIdResult?(req.uniqueId)
        asyncManager.sendData(sendable: req)
    }

    func prepareToSendAsync(req: ChatSendable, uniqueIdResult: UniqueIdResultType? = nil) {
        uniqueIdResult?(req.uniqueId)
        asyncManager.sendData(sendable: req)
    }

    public func setToken(newToken: String, reCreateObject: Bool = false) {
        config.token = newToken
        if reCreateObject {
            asyncManager.createAsync()
        }
    }

    internal func setUser(user: User) {
        userInfo = user
    }

    func startCrashAnalytics() {
        // Config for Sentry 4.3.1
        do {
            Client.shared = try Client(dsn: "https://5e236d8a40be4fe99c4e8e9497682333:5a6c7f732d5746e8b28625fcbfcbe58d@chatsentryweb.sakku.cloud/4")
            try Client.shared?.startCrashHandler()
        } catch {
            print("\(error)")
        }
    }
}
