//
// Chat+.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import FanapPodAsyncSDK
import Foundation

protocol ChatProtocol: AnyObject {
    /// The unique id of a chat instance to find and use it in ``ChatManager`` to fetch it.
    var id: UUID { get set }

    /// A delegation property to emit events and errors and connection status of the object.
    var delegate: ChatDelegate? { get set }

    /// A manager for the chat object that will manage and holds the strong reference of a callback to invoke and then remove after the invocation.
    var callbacksManager: CallbacksManager { get }

    /// A configuration of the chat. Please use the ``ChatConfigBuilder`` to build this object easier.
    var config: ChatConfig { get set }

    /// A variable that determines how many times the user is typing is sent to the other participants.
    var isTypingCount: Int { get set }

    /// The timer for sending user is typing.
    var timerTyping: TimerProtocol? { get set }

    /// A timer to stop user is typing event.
    var timerCheckUserStoppedTyping: TimerProtocol? { get set }

    /// A timer for retrieving the ``User`` object to make the ``ChatState/chatReady``.
    var requestUserTimer: TimerProtocol { get set }

    /// Number of retry count to retrieve the user.
    var userRetrycount: Int { get set }

    /// Max number of retry to fetch user object.
    var maxUserRetryCount: Int { get }

    /// The object of the current user will automatically be filled by the SDK after ``ChatState/asyncReady``,
    /// and if it is fetched properly, it will change the state of the chat to ``ChatState/chatReady``.
    var userInfo: User? { get set }

    /// A private method for fetching the user for first time.
    func getUserForChatReady()

    /// An async manager to keep the socket connection live and deliver messages and also cache the requests if they need it.
    var asyncManager: AsyncManager { get set }

    /// A logger to logs events if it is enabled in configuration ``ChatConfig/isDebuggingLogEnabled``.
    var logger: Logger? { get set }

    /// An array to manage a list of threads in the queue of exporting messages of a thread.
    var exportMessageViewModels: [any ExportMessagesProtocol] { get set }

    /// A url session to initiate a network call.
    var session: URLSessionProtocol { get set }

    /// A queue in which the response will call which is by default is ``DispatchQueue.main``.
    var responseQueue: DispatchQueueProtocol { get set }

    /// A cache object to store and give you the opportunity to retrieve data from it.
    var cache: CacheFactory { get set }

    /// A token setter to update token.
    /// - Parameters:
    ///   - newToken: The token string.
    ///   - reCreateObject: If you set it to true the chat object will recreate itself and will reconnect completely.
    func setToken(newToken: String, reCreateObject: Bool)

    /// It is a private method and only should used by the SDK to send data to ``AsyncManager`` and send to ``Async``.
    /// - Parameters:
    ///   - req: A object that conform to the ``ChatSendable``.
    ///   - uniqueIdResult: A unique ID should be filled by the client or the SDK.
    ///   - completion: A completion handler to send data result back.
    ///   - onSent: A completion handler for onSent message.
    ///   - onDelivered: A completion handler for onDelivered message.
    ///   - onSeen: A completion handler for onSeen message.
    func prepareToSendAsync<T: Decodable>(
        req: ChatSendable,
        uniqueIdResult: UniqueIdResultType?,
        completion: CompletionType<T>?,
        onSent: OnSentType?,
        onDelivered: OnDeliveryType?,
        onSeen: OnSeenType?
    )

    /// It is a private method and only should used by the SDK to send data to ``AsyncManager`` and send to ``Async``.
    /// - Parameters:
    ///   - req: A object that conform to the ``ChatSendable``.
    ///   - uniqueIdResult: A unique ID should be filled by the client or the SDK.
    func prepareToSendAsync(req: ChatSendable, uniqueIdResult: UniqueIdResultType?)

    /// A method to destroy a chat object and release all strong reference objects.
    func dispose()

    /// A method that should be called by clients whenever they fill it is the right time to connect to the server.
    func connect()

    /// Crach manager.
    func startCrashAnalytics()

    /// A private method that will be called by the SDK to pass data that received from onMessage.
    func invokeCallback(asyncMessage: AsyncMessage)
}
