//
// ChatProtocol.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

@_exported import Additive
@_exported import Async
@_exported import ChatCache
@_exported import ChatCore
@_exported import ChatDTO
@_exported import ChatModels
@_exported import ChatTransceiver
@_exported import ChatExtensions
import Foundation
import Logger

public protocol Chat {
    init(
        config: ChatConfig,
        pingTimer: SourceTimer,
        queueTimer: SourceTimer,
        banTimer: TimerProtocol,
        session: URLSessionProtocol,
        callDelegate: WebRTCClientDelegate?
    )

    /// The unique id of a chat instance to find and use it in ``ChatManager`` to fetch it.
    var id: UUID { get }

    var contact: ContactProtocol { get set }
    var conversation: ThreadProtocol { get set }
    var bot: BotProtocol { get set }
    var map: MapProtocol { get set }
    var file: FileProtocol { get set }
    var message: MessageProtocol { get set }
    var tag: TagProtocol { get set }
    var user: UserProtocol { get set }
    var assistant: AssistantProtocol { get set }
    var system: SystemProtocol { get set }
    var reaction: ReactionProtocol { get set }

    /// The current userInfo is set by the SDK after the connection gets ready.
    var userInfo: User? { get }

    /// A delegation property to emit events and errors and connection status of the object.
    var delegate: ChatDelegate? { get set }

    /// Last state of the chat object.
    var state: ChatState { get }

    /// A configuration of the chat. Please use the ``ChatConfigBuilder`` to build this object easier.
    var config: ChatConfig { get set }

    /// A token setter to update token.
    /// - Parameters:
    ///   - newToken: The token string.
    ///   - reCreateObject: If you set it to true the chat object will recreate itself and will reconnect completely.
    func setToken(newToken: String, reCreateObject: Bool)

    /// A method to destroy a chat object and release all strong reference objects.
    func dispose()

    /// A method that should be called by clients whenever they fill it is the right time to connect to the server.
    func connect()
}

public protocol ChatInternalProtocol: Chat {
    var coordinator: ChatCoordinator { get set }
    /// A timer that will retry if the user rapidly tries to send action to the chat server.
    /// Chat server usually bans the user if it sends more than 3 requests in less than a second.
    var banTimer: TimerProtocol { get set }

    /// The object of the current user will automatically be filled by the SDK after ``ChatState/asyncReady``,
    /// and if it is fetched properly, it will change the state of the chat to ``ChatState/chatReady``.
    var userInfo: User? { get set }

    /// An async manager to keep the socket connection live and deliver messages and also cache the requests if they need it.
    var asyncManager: AsyncManager { get set }

    /// A logger to logs events if it is enabled in configuration ``ChatConfig/isDebuggingLogEnabled``.
    var logger: Logger { get set }

    /// An array to manage a list of threads in the queue of exporting messages of a thread.
    var exportMessageViewModels: [ExportMessagesProtocol] { get set }

    /// A url session to initiate a network call.
    var session: URLSessionProtocol { get set }

    /// A manager that keeps all concrete object of cache managers.
    var cache: CacheManager? { get set }

    /// A file manager for caching files on the storage.
    var cacheFileManager: CacheFileManagerProtocol? { get set }

    /// A delegate for communicating with ChatCall SDK.
    var callMessageDeleaget: CallMessageProtocol? { get set }

    /// It is a private method and only should used by the SDK to send data to ``AsyncManager`` and send to ``Async``.
    /// - Parameters:
    ///   - req: A object that conform to the ``ChatSendable``.
    func prepareToSendAsync(req: ChatSendable, type: ChatMessageVOTypes)

    /// A private method that will be called by the SDK to pass data that received from onMessage.
    func invokeCallback(asyncMessage: AsyncMessage)

    /// Dispose and close object.
    func dispose()

    var loggerUserInfo: [String: String] { get }
}
