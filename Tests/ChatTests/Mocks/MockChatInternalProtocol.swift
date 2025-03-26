//
// MockChatInternalProtocol.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
@testable import Chat
@testable import Logger

final class MockChatInternalProtocol: ChatInternalProtocol, CacheLogDelegate {
    var delegate: (any ChatDelegate)?
    var state: ChatState = .uninitialized
    var config: ChatConfig

    var id: UUID = .init()
    public lazy var contact: ContactProtocol = ContactManager(chat: self)
    public lazy var conversation: ThreadProtocol = ThreadManager(chat: self)
    public lazy var bot: BotProtocol = BotManager(chat: self)
    public lazy var map: MapProtocol = MapManager(chat: self)
    public lazy var file: FileProtocol = ChatFileManager(chat: self)
    public lazy var message: MessageProtocol = MessageManager(chat: self)
    public lazy var tag: TagProtocol = TagManager(chat: self)
    public lazy var user: UserProtocol = UserManager(chat: self)
    public lazy var assistant: AssistantProtocol = AssistantManager(chat: self)
    public lazy var system: SystemProtocol = SystemManager(chat: self)
    public lazy var reaction: ReactionProtocol = ReactionManager(chat: self)
    public lazy var coordinator: ChatCoordinator = ChatCoordinator(chat: self)

    var banTimer: any TimerProtocol
    var userInfo: User?
    var asyncManager: AsyncManager
    var logger: Logger
    var exportMessageViewModels: [ExportMessagesProtocol] = []
    var session: any URLSessionProtocol
    var cache: CacheManager?
    var cacheFileManager: (any CacheFileManagerProtocol)?
    var callMessageDeleaget: (any CallMessageProtocol)?
    public var callDelegate: WebRTCClientDelegate?
    var loggerUserInfo: [String : String] = [:]

    required init(config: ChatConfig,
                  pingTimer: SourceTimer,
                  queueTimer: SourceTimer,
                  banTimer: any TimerProtocol,
                  session: any URLSessionProtocol,
                  callDelegate: (any WebRTCClientDelegate)?) {
        self.config = config
        self.banTimer = banTimer
        self.session = session
        self.callDelegate = callDelegate
        logger = Logger(config: config.loggerConfig)
        asyncManager = AsyncManager(pingTimer: pingTimer, queueTimer: queueTimer)
        if config.enableCache {
            cacheFileManager = CacheFileManager()
            cache = CacheManager(persistentManager: PersistentManager(logger: self))
        }
        asyncManager.chat = self
    }

    func setToken(newToken: String, reCreateObject: Bool) {

    }

    func connect() {
        if config.getDeviceIdFromToken == false {
            asyncManager.createAsync()
        } else {
            requestDeviceId()
        }
    }

    private func requestDeviceId() {
        let url = "\(config.ssoHost)\(Routes.ssoDevices.rawValue)"
        let headers = ["Authorization": "Bearer \(config.token)"]
        var urlReq = URLRequest(url: URL(string: url)!)
        urlReq.allHTTPHeaderFields = headers
        session.dataTask(urlReq) { [weak self] data, response, error in
            let result: ChatResponse<DevicesResposne>? = self?.session.decode(data, response, error, typeCode: nil)
            if let device = result?.result?.devices?.first(where: { $0.current == true }) {
                self?.config.asyncConfig.updateDeviceId(device.uid ?? UUID().uuidString)
                self?.asyncManager.createAsync()
            }
        }
        .resume()
    }

    func invokeCallback(asyncMessage: AsyncMessage) {

    }

    func prepareToSendAsync(req: any ChatSendable, type: ChatMessageVOTypes) {

    }

    func dispose() {

    }

    func log(message: String, persist: Bool, error _: Error?) {
        logger.log(message: message, persist: persist, type: .internalLog)
    }

    public static func shared(delegate: ChatDelegate? = nil) -> MockChatInternalProtocol {
        let config = ChatConfig(asyncConfig: MockAsyncConfig.defaultConfig,
                                callConfig: .init(),
                                token: "test",
                                ssoHost: "",
                                platformHost: "",
                                fileServer: "",
                                typeCodes: [.init(typeCode: "default", ownerId: nil)]
        )
        let pingTimer = SourceTimer()
        let queueTimer = SourceTimer()
        let banTimer = Timer()
        let chat = MockChatInternalProtocol(config: config,
                                            pingTimer: pingTimer,
                                            queueTimer: queueTimer,
                                            banTimer: banTimer,
                                            session: URLSession.shared,
                                            callDelegate: nil)
        chat.delegate = delegate
        return chat
    }
}

final class MockAsyncConfig {
    static let defaultConfig: AsyncConfig = {
        let asyncLoggerConfig = LoggerConfig(prefix: "ASYNC_SDK",
                                             logServerURL: "http://10.56.34.61:8080/1m-http-server-test-chat",
                                             logServerMethod: "PUT",
                                             persistLogsOnServer: true,
                                             isDebuggingLogEnabled: true,
                                             logServerRequestheaders: ["Authorization": "Basic Y2hhdDpjaGF0MTIz", "Content-Type": "application/json"])

        let config = try! AsyncConfig(socketAddress: "wss://msg.pod.ir/ws",
                                      peerName: "chat-server",
                                      appId: "PodChat",
                                      loggerConfig: asyncLoggerConfig,
                                      reconnectOnClose: true)
        return config
    }()
}
