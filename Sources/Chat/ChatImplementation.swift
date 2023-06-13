//
// ChatImplementation.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/16/22

import Additive
import Async
import ChatCache
import ChatCore
import ChatDTO
import ChatModels
import Foundation
import Logger

public final class ChatImplementation: ChatInternalProtocol, Identifiable {
    public lazy var contact: ContactProtocol = { ContactManager(chat: self) }()
    public lazy var conversation: ThreadProtocol = { ThreadManager(chat: self) }()
    public lazy var bot: BotProtocol = { BotManager(chat: self) }()
    public lazy var map: MapProtocol = { MapManager(chat: self) }()
    public lazy var file: FileProtocol = { ChatFileManager(chat: self) }()
    public lazy var message: MessageProtocol = { MessageManager(chat: self) }()
    public lazy var tag: TagProtocol = { TagManager(chat: self) }()
    public lazy var user: UserProtocol = { UserManager(chat: self) }()
    public lazy var participant: ParticipantProtocol = { ParticipantManager(chat: self) }()
    public lazy var assistant: AssistantProtocol  = { AssistantManager(chat: self) }()
    public lazy var system: SystemProtocol = { SystemManager(chat: self) }()

    public var id: UUID = .init()
    public var config: ChatConfig
    public weak var delegate: ChatDelegate? {
        didSet {
            logger.delegate = delegate
        }
    }

    public var userInfo: User?
    public var asyncManager: AsyncManager
    public var logger: Logger
    public var banTimer: TimerProtocol
    public var exportMessageViewModels: [ExportMessagesProtocol] = []
    public var session: URLSessionProtocol
    public var responseQueue: DispatchQueueProtocol
    public var cache: CacheManager?
    public let callbacksManager = CallbacksManager()
    public var cacheFileManager: CacheFileManagerProtocol?
    public var state: ChatState = .uninitialized
    public var callMessageDeleaget: CallMessageProtocol?
    public var callDelegate: WebRTCClientDelegate?

    public init(config: ChatConfig,
                pingTimer: TimerProtocol = Timer(),
                queueTimer: TimerProtocol = Timer(),
                banTimer: TimerProtocol = Timer(),
                session: URLSessionProtocol = URLSession.shared,
                callDelegate: WebRTCClientDelegate? = nil,
                responseQueue: DispatchQueueProtocol = DispatchQueue.main)
    {
        self.responseQueue = responseQueue
        self.config = config
        logger = Logger(config: config.loggerConfig)
        self.banTimer = banTimer
        self.session = session
        self.callDelegate = callDelegate
        asyncManager = AsyncManager(pingTimer: pingTimer, queueTimer: queueTimer)
        if config.enableCache {
            cacheFileManager = CacheFileManager()
            cache = CacheManager(persistentManager: PersistentManager(logger: self))
        }
        asyncManager.chat = self
    }

    public func connect() {
        if config.getDeviceIdFromToken == false {
            asyncManager.createAsync()
        } else {
            requestDeviceId()
        }
        DiskStatus.checkIfDeviceHasFreeSpace(needSpaceInMB: config.deviecLimitationSpaceMB, turnOffTheCache: true, delegate: delegate)
    }

    public func dispose() {
        asyncManager.disposeObject()
    }

    public func prepareToSendAsync<T: Decodable>(
        req: ChatSendable,
        type: ChatMessageVOTypes,
        uniqueIdResult: UniqueIdResultType? = nil,
        completion: CompletionType<T>? = nil,
        onSent: OnSentType? = nil,
        onDelivered: OnDeliveryType? = nil,
        onSeen: OnSeenType? = nil
    ) {
        callbacksManager.addCallback(uniqueId: req.chatUniqueId, requesType: type, callback: completion, onSent: onSent, onDelivered: onDelivered, onSeen: onSeen)
        uniqueIdResult?(req.chatUniqueId)
        asyncManager.sendData(sendable: req, type: type)
    }

    public func prepareToSendAsync(req: ChatSendable, type: ChatMessageVOTypes, uniqueIdResult: UniqueIdResultType? = nil) {
        uniqueIdResult?(req.chatUniqueId)
        asyncManager.sendData(sendable: req, type: type)
    }

    public func prepareToSendAsync(req: ChatCore.ChatSendable, type: ChatCore.ChatMessageVOTypes) {
        asyncManager.sendData(sendable: req, type: type)
    }

    public func setToken(newToken: String, reCreateObject: Bool = false) {
        config.updateToken(newToken)
        if reCreateObject {
            asyncManager.createAsync()
        }
    }

    private func requestDeviceId() {
        let url = "\(config.ssoHost)\(Routes.ssoDevices.rawValue)"
        let headers = ["Authorization": "Bearer \(config.token)"]
        var urlReq = URLRequest(url: URL(string: url)!)
        urlReq.allHTTPHeaderFields = headers
        session.dataTask(urlReq) { [weak self] data, response, error in
            let result: ChatResponse<DevicesResposne>? = self?.session.decode(data, response, error)
            self?.responseQueue.async {
                if let device = result?.result?.devices?.first(where: { $0.current == true }) {
                    self?.config.asyncConfig.updateDeviceId(device.uid ?? UUID().uuidString)
                    self?.asyncManager.createAsync()
                }
            }
        }
        .resume()
    }
}
