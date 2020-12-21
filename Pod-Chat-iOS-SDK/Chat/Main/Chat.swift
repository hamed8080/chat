//
//  Chat.swift
//  Chat
//
//  Created by Mahyar Zhiani on 5/21/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import FanapPodAsyncSDK
import CoreData
import Alamofire
import SwiftyJSON
//import UIKit
//import Contacts
import Sentry
import Each
//import Firebase


public class Chat {
    
    // MARK: - Chat initializer
    public init() {
        
    }
    
//    public static let sharedInstance = Chat()
    
    struct Static {
        public static var instance: Chat?
    }
    
    open class var sharedInstance: Chat {
        if Static.instance == nil {
            Static.instance = Chat()
        }
        return Static.instance!
    }
    
    
    public func disposeChatObject() {
        stopAllChatTimers()
        asyncClient?.disposeAsyncObject()
        asyncClient = nil
        Chat.Static.instance = nil
        print("Disposed Singleton instance")
//        Chat.sharedInstance = nil
    }
    
    public func createChatObject(socketAddress:             String,
                                 ssoHost:                   String,
                                 platformHost:              String,
                                 fileServer:                String,
                                 serverName:                String,
                                 token:                     String,
                                 mapApiKey:                 String?,
                                 mapServer:                 String,
                                 typeCode:                  String?,
                                 enableCache:               Bool,
                                 cacheTimeStampInSec:       Int?,
                                 msgPriority:               Int?,
                                 msgTTL:                    Int?,
                                 httpRequestTimeout:        Int?,
                                 actualTimingLog:           Bool?,
                                 wsConnectionWaitTime:      Double,
                                 connectionRetryInterval:   Int,
                                 connectionCheckTimeout:    Int,
                                 messageTtl:                Int,
                                 getDeviceIdFromToken:      Bool,
                                 captureLogsOnSentry:       Bool,
                                 maxReconnectTimeInterval:  Int?,
                                 reconnectOnClose:          Bool,
                                 localImageCustomPath:      URL?,
                                 localFileCustomPath:       URL?,
                                 deviecLimitationSpaceMB:   Int64?,
                                 showDebuggingLogLevel:     ConsoleLogLevel?) {
        
        self.debuggingLogLevel = showDebuggingLogLevel?.logLevel() ?? LogLevel.error
        
        self.captureSentryLogs = captureLogsOnSentry
        if captureLogsOnSentry {
            startCrashAnalitics()
        }
        
        self.socketAddress      = socketAddress
        self.ssoHost            = ssoHost
        self.platformHost       = platformHost
        self.fileServer         = fileServer
        self.serverName         = serverName
        self.token              = token
        self.enableCache        = enableCache
        self.mapServer          = mapServer
        
        if let timeStamp = cacheTimeStampInSec {
            cacheTimeStamp = timeStamp
        }
        
        if let theMapApiKey = mapApiKey {
            self.mapApiKey = theMapApiKey
        }
        
        if let theTypeCode = typeCode {
            self.generalTypeCode = theTypeCode
        }
        
        if let theMsgPriority = msgPriority {
            self.msgPriority = theMsgPriority
        }
        
        if let theMsgTTL = msgTTL {
            self.msgTTL = theMsgTTL
        }
        
        if let theHttpRequestTimeout = httpRequestTimeout {
            self.httpRequestTimeout = theHttpRequestTimeout
        }
        
        if let theActualTimingLog = actualTimingLog {
            self.actualTimingLog = theActualTimingLog
        }
        
        if let timeLimitation = deviecLimitationSpaceMB {
            self.deviecLimitationSpaceMB = timeLimitation
        }
        
        self.wsConnectionWaitTime       = wsConnectionWaitTime
        self.connectionRetryInterval    = connectionRetryInterval
        self.connectionCheckTimeout     = connectionCheckTimeout
        self.messageTtl                 = messageTtl
        self.reconnectOnClose           = reconnectOnClose
        self.maxReconnectTimeInterval   = maxReconnectTimeInterval ?? 60
        
        self.SERVICE_ADDRESSES.SSO_ADDRESS          = ssoHost
        self.SERVICE_ADDRESSES.PLATFORM_ADDRESS     = platformHost
        self.SERVICE_ADDRESSES.FILESERVER_ADDRESS   = fileServer
        self.SERVICE_ADDRESSES.MAP_ADDRESS          = mapServer
        
        self.localImageCustomPath = localImageCustomPath
        self.localFileCustomPath = localFileCustomPath
        
        if getDeviceIdFromToken {
            getDeviceIdWithToken { (deviceIdStr) in
                self.deviceId = deviceIdStr
                log.info("get deviceId successfully = \(self.deviceId ?? "error!!")", context: "Chat")
                
                DispatchQueue.main.async {
                    self.CreateAsync()
                }
            }
        } else {
            DispatchQueue.main.async {
                self.CreateAsync()
            }
        }
        
        if checkIfDeviceHasFreeSpace(needSpaceInMB: self.deviecLimitationSpaceMB, turnOffTheCache: true) {
//            self.enableCache = false
        }
        
    }
    
    private func startCrashAnalitics() {
        
        // Config for Sentry 4.3.1
        do {
            Client.shared = try Client(dsn: "https://5e236d8a40be4fe99c4e8e9497682333:5a6c7f732d5746e8b28625fcbfcbe58d@chatsentryweb.sakku.cloud/4")
            try Client.shared?.startCrashHandler()
        } catch let error {
            print("\(error)")
        }
        
        // Config for Sentry 5.0.5
//        SentrySDK.start(options: [
//            "dsn": "https://a06c7828c36d47c7bbb24605ba5d0d26@o376741.ingest.sentry.io/5198368",
//            "debug": true // Helpful to see what's going on. (Enabled debug when first installing is always helpful)
//        ])
//        let event = Event(level: SentryLevel.error)
//        event.message = "Test Sentry on Sakku"
//        SentrySDK.capture(event: event)
//        print("send message to sentry")
    }
    
    func startNotification() {
//        FirebaseApp.configure()
//        if #available(iOS 10.0, *) {
//          // For iOS 10 display notification (sent via APNS)
//          UNUserNotificationCenter.current().delegate = self
//
//          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
//          UNUserNotificationCenter.current().requestAuthorization(
//            options: authOptions,
//            completionHandler: {_, _ in })
//        } else {
//          let settings: UIUserNotificationSettings =
//          UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
//          Chat.sharedInstance.registerUserNotificationSettings(settings)
//        }
    }
    
    
    func asccessNotificationRegisterationToken() {
//        Messaging.messaging().delegate = self
    }
    
    func getNotificationToken() {
//        InstanceID.instanceID().instanceID { (result, error) in
//          if let error = error {
//            print("Error fetching remote instance ID: \(error)")
//          } else if let result = result {
//            print("Remote instance ID token: \(result.token)")
//            self.instanceIDTokenMessage.text  = "Remote InstanceID token: \(result.token)"
//          }
//        }
    }
    
    
    
    
    // the delegate property that the user class should make itself to be implment this delegat.
    // At first, the class sould confirm to ChatDelegates, and then implement the ChatDelegates methods
    public weak var delegate: ChatDelegates?
    
    // create cache instance to use cache...
    static let cacheDB = Cache()
    
    
    var debuggingLogLevel: LogLevel = .error
    
    // MARK: - setup properties
    
    var socketAddress:  String  = ""        // Address of the Socket Server
    var ssoHost:        String  = ""        // Address of the SSO Server (SERVICE_ADDRESSES.SSO_ADDRESS)
    var platformHost:   String  = ""        // Address of the platform (SERVICE_ADDRESSES.PLATFORM_ADDRESS)
    var fileServer:     String  = ""        // Address of the FileServer (SERVICE_ADDRESSES.FILESERVER_ADDRESS)
    var serverName:     String  = ""        // Name of the server that we had registered on
    var token:          String  = ""        // every user have to had a token (get it from SSO Server)
    var generalTypeCode:    String  = "default"
    public var enableCache: Bool    = false
    var mapApiKey:          String  = "8b77db18704aa646ee5aaea13e7370f4f88b9e8c"
    var mapServer:          String  = "https://api.neshan.org/v1"
    
//    var ssoGrantDevicesAddress = params.ssoGrantDevicesAddress
    var chatFullStateObject: ChatFullStateModel?
    
    var msgPriority:        Int     = 1
    var msgTTL:             Int     = 10
    var httpRequestTimeout: Int     = 20
    var actualTimingLog:    Bool    = false
    
    var wsConnectionWaitTime:       Double = 0.0
    var connectionRetryInterval:    Int = 10000
    var connectionCheckTimeout:     Int = 10000
    var messageTtl:                 Int = 10000
    var reconnectOnClose:           Bool = false
    var maxReconnectTimeInterval:   Int = 60
    
//    var imageMimeTypes = ["image/bmp", "image/png", "image/tiff", "image/gif", "image/x-icon", "image/jpeg", "image/webp"]
//    var imageExtentions = ["bmp", "png", "tiff", "tiff2", "gif", "ico", "jpg", "jpeg", "webp"]
    
    var asyncClient:    Async?
    var deviceId:       String?
    var peerId:         Int?
    var oldPeerId:      Int?
    var userInfo:       User?
    
    var localImageCustomPath: URL?
    var localFileCustomPath: URL?
    
    var getHistoryCount         = 50
    var getUserInfoRetry        = 5
    var getUserInfoRetryCount   = 0
    var chatPingMessageInterval = 20
    var cacheTimeStamp          = (2 * 24) * (60 * 60)
    var deviecLimitationSpaceMB: Int64 = 100
    
    var captureSentryLogs = false
    
    var isChatReady     = false {
        didSet {
            if isChatReady {
                for item in sendRequestQueue {
                    sendRequestToAsync(type: item.type, content: item.content)
                }
            }
        }
    }
    
    var SERVICE_ADDRESSES = SERVICE_ADDRESSES_ENUM()
    
    var sendRequestQueue:       [(type: Int, content: String)]          = []
    public var uploadRequest:   [(upload: Request, uniqueId: String)]   = []
    public var downloadRequest: [(download: Request, uniqueId: String)] = []
    
//    var repeatTimer: Timer?
//    var signalMessageInput: SendSignalMessageRequestModel?
//    var isTypingOnThread: Int = 0 {
//        didSet {
//            var count = 0
//            signalMessageInput = SendSignalMessageRequestModel(signalType:  SignalMessageType.IS_TYPING,
//                                                               threadId:    isTypingOnThread,
//                                                               uniqueId:    nil)
//
//            repeatTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { (timer) in
//                if (count > 30) || (self.isTypingOnThread == 0) {
//                    if timer.isValid {
//                        timer.invalidate()
//                    }
//                } else if let inputModel = self.signalMessageInput {
//                    self.sendSignalMessage(input: inputModel)
//                    count += 1
//                }
//            }
//
////            if (isTypingOnThread == 0) {
////                repeatTimer?.invalidate()
////                repeatTimer = nil
////            } else {
////                repeatTimer?.fire()
////            }
//
//        }
//    }
    
    var isTypingCount = 0
    var sendIsTypingMessageTimer: (timer: RepeatingTimer?, onThread: Int)? {
        didSet {
            isTypingCount = 0
            if (sendIsTypingMessageTimer != nil) {
                sendIsTypingMessageTimer?.timer?.eventHandler = {
                    if (self.isTypingCount < 30) {
                        self.isTypingCount += 1
                        DispatchQueue.main.async {
                            let signalMessageInput = SendSignalMessageRequestModel(signalType:  SignalMessageType.IS_TYPING,
                                                                                   threadId:    self.sendIsTypingMessageTimer!.onThread,
                                                                                   uniqueId:    nil)
                            self.sendSignalMessage(input: signalMessageInput)
                        }
                    } else {
                        self.sendIsTypingMessageTimer!.timer?.suspend()
                        self.sendIsTypingMessageTimer = nil
                    }
                }
                sendIsTypingMessageTimer?.timer?.resume()
            }
        }
    }
    
    
    
    // MARK: - Timers
    
    var getUserInfoTimer: RepeatingTimer? {
        didSet {
            if (getUserInfoTimer != nil) {
                log.verbose("getUserInfoTimer valueChanged: \n staus = \(self.getUserInfoTimer!.state) - timeInterval = \(self.getUserInfoTimer!.timeInterval) \n isChatReady = \(isChatReady)", context: "Chat")
                self.getUserInfoTimer?.suspend()
                
                if !isChatReady {
                    DispatchQueue.global().async {
                        self.getUserInfoTimer?.eventHandler = {
                            if (self.getUserInfoRetryCount < self.getUserInfoRetry) {
                                DispatchQueue.main.async {
                                    self.makeChatReady()
                                }
                                self.getUserInfoTimer?.suspend()
                            }
                        }
                        self.getUserInfoTimer?.resume()
                    }
                }
            } else {
                log.verbose("getUserInfoTimer valueChanged to nil. \n isChatReady = \(isChatReady)", context: "Chat")
            }
            
        }
    }
    
    
    
    var lastReceivedMessageTime:    Date?
    var lstRcvdMsgTimer: Each?
    
    func lastReceivedMessageTimer(interval: TimeInterval) {
//        log.debug("Chat: lastReceivedMessageTimer is called: \n timerIsStopped = \(lstRcvdMsgTimer?.isStopped) \n timeInterval = \(interval) \n lastReceivedMessageTime = \(lastReceivedMessageTime ?? Date())", context: "Chat")
//        DispatchQueue.global().async {
        self.lstRcvdMsgTimer = Each(interval).seconds
        lastReceivedMessageTime = Date()
        self.lstRcvdMsgTimer!.perform {
            if let lastReceivedMessageTimeBanged = self.lastReceivedMessageTime {
                let elapsed = Int(Date().timeIntervalSince(lastReceivedMessageTimeBanged))
                if (elapsed >= self.connectionCheckTimeout) {
                    DispatchQueue.main.async {
                        self.asyncClient?.asyncReconnectSocket()
                    }
                    self.lstRcvdMsgTimer!.restart()
                }
            }
            return .continue
        }
//        }
    }
    
//    var lastReceivedMessageTime:    Date?
//    var lastReceivedMessageTimer:   RepeatingTimer? {
//        didSet {
//            if (lastReceivedMessageTimer != nil) {
//                log.verbose("Chat: lastReceivedMessageTimer valueChanged: \n staus = \(self.lastReceivedMessageTimer!.state) \n timeInterval = \(self.lastReceivedMessageTimer!.timeInterval) \n lastReceivedMessageTime = \(lastReceivedMessageTime ?? Date())", context: "Chat")
//                self.lastReceivedMessageTimer?.suspend()
//                DispatchQueue.global().async {
//                    self.lastReceivedMessageTime = Date()
//                    self.lastReceivedMessageTimer?.eventHandler = {
//                        if let lastReceivedMessageTimeBanged = self.lastReceivedMessageTime {
//                            let elapsed = Int(Date().timeIntervalSince(lastReceivedMessageTimeBanged))
//                            if (elapsed >= self.connectionCheckTimeout) {
//                                DispatchQueue.main.async {
//                                    self.asyncClient?.asyncReconnectSocket()
//                                }
//                                self.lastReceivedMessageTimer?.suspend()
//                            }
//                        }
//                    }
//                    self.lastReceivedMessageTimer?.resume()
//                }
//            } else {
//                log.verbose("Chat: lastReceivedMessageTimer valueChanged to nil.\n lastReceivedMessageTime = \(lastReceivedMessageTime ?? Date())", context: "Chat")
//            }
//        }
//    }
    
    
    
    
    
    var lastSentMessageTime:    Date?
    var lstSntMsgTimer:         Each?
    
    func lastSentMessageTimer(interval: TimeInterval) {
//        log.debug("Chat: lastSentMessageTimer callled: \n timerIsStopped = \(lstSntMsgTimer?.isStopped) \n timeInterval = \(interval) \n lastSentMessageTime = \(lastSentMessageTime ?? Date())", context: "Chat")
//        DispatchQueue.global().async {
        lstSntMsgTimer = Each(interval).seconds
        lastSentMessageTime = Date()
        lstSntMsgTimer!.perform {
            if let lastSendMessageTimeBanged = self.lastSentMessageTime {
                let elapsed = Int(Date().timeIntervalSince(lastSendMessageTimeBanged))
                if (elapsed >= self.chatPingMessageInterval) && (self.isChatReady == true) {
                    DispatchQueue.main.async {
                        self.ping()
                    }
                    self.lstSntMsgTimer!.restart()
                }
            }
            return .continue
        }
//        }
        
    }
    
//    var lastSentMessageTime:    Date?
//    var lastSentMessageTimer:   RepeatingTimer? {
//        didSet {
//            /*
//             * first of all, it will suspend the timer
//             * then on the background thread it will run a timer
//             * if the "isChatReady" = true (means chat is still connected)
//             * and there are "chatPingMessageInterval" seconds passed from last message that sends to chat
//             * it will send a ping message on the main thread
//             *
//             */
//            if (lastSentMessageTimer != nil) {
//                log.verbose("Chat: lastSentMessageTimer valueChanged: \n staus = \(self.lastSentMessageTimer!.state) \n timeInterval = \(self.lastSentMessageTimer!.timeInterval) \n lastSentMessageTime = \(lastSentMessageTime ?? Date())", context: "Chat")
//                self.lastSentMessageTimer?.suspend()
//                DispatchQueue.global().async {
//                    self.lastSentMessageTime = Date()
//                    self.lastSentMessageTimer?.eventHandler = {
//                        if let lastSendMessageTimeBanged = self.lastSentMessageTime {
//                            let elapsed = Int(Date().timeIntervalSince(lastSendMessageTimeBanged))
//                            if (elapsed >= self.chatPingMessageInterval) && (self.isChatReady == true) {
//                                DispatchQueue.main.async {
//                                    self.ping()
//                                }
//                                self.lastSentMessageTimer?.suspend()
//                            }
//                        }
//                    }
//                    self.lastSentMessageTimer?.resume()
//                }
//            } else {
//                log.verbose("Chat: lastSentMessageTimer valueChanged to nil.\n lastSentMessageTime = \(lastSentMessageTime ?? Date())", context: "Chat")
//            }
//
//        }
//    }
    
    
    // MARK: - properties that save callbacks on themselves
    
    // property to hold array of request that comes from client, but they have not completed yet (response didn't come yet)
    // the keys are uniqueIds of the requests
    static var map          = [String: CallbackProtocol]()
    static var mentionMap   = [String: CallbackProtocol]()
    static var spamMap      = [String: [CallbackProtocol]]()
    
    // property to hold array of Sent, Deliver and Seen requests that comes from client, but they have not completed yet, and response didn't come yet.
    // the keys are uniqueIds of the requests
    static var mapOnSent    = [String: CallbackProtocolWith3Calls]()
    static var mapOnDeliver = [String: [[String: CallbackProtocolWith3Calls]]]()
    static var mapOnSeen    = [String: [[String: CallbackProtocolWith3Calls]]]()
    
    // property to hold Sent callbecks to implement later, on somewhere else on the program
    public var userInfoCallbackToUser:              callbackTypeAlias?
    public var getContactsCallbackToUser:           callbackTypeAlias?
    public var threadsCallbackToUser:               callbackTypeAlias?
    public var getAllUnreadMessagesCountCallbackToUser: callbackTypeAlias?
    public var getHistoryCallbackToUser:            callbackTypeAlias?
    public var getMentionListCallbackToUser:        callbackTypeAlias?
    public var threadParticipantsCallbackToUser:    callbackTypeAlias?
    public var createThreadCallbackToUser:          callbackTypeAlias?
    public var closeThreadCallbackToUser:           callbackTypeAlias?
    public var addParticipantsCallbackToUser:       callbackTypeAlias?
    public var removeParticipantsCallbackToUser:    callbackTypeAlias?
    public var sendCallbackToUserOnSent:            callbackTypeAlias?
    public var sendCallbackToUserOnDeliver:         callbackTypeAlias?
    public var sendCallbackToUserOnSeen:            callbackTypeAlias?
    public var editMessageCallbackToUser:           callbackTypeAlias?
    public var deleteMessageCallbackToUser:         callbackTypeAlias?
    public var muteThreadCallbackToUser:            callbackTypeAlias?
    public var unmuteThreadCallbackToUser:          callbackTypeAlias?
    public var updateThreadInfoCallbackToUser:      callbackTypeAlias?
    public var blockCallbackToUser:                 callbackTypeAlias?
    public var unblockUserCallbackToUser:           callbackTypeAlias?
    public var getBlockedListCallbackToUser:        callbackTypeAlias?
    public var leaveThreadCallbackToUser:           callbackTypeAlias?
    public var spamPvThreadCallbackToUser:          callbackTypeAlias?
    public var getMessageSeenListCallbackToUser:    callbackTypeAlias?
    public var getMessageDeliverListCallbackToUser: callbackTypeAlias?
    public var clearHistoryCallbackToUser:          callbackTypeAlias?
    public var setRoleToUserCallbackToUser:         callbackTypeAlias?
    public var removeRoleFromUserCallbackToUser:    callbackTypeAlias?
    public var pinThreadCallbackToUser:             callbackTypeAlias?
    public var unpinThreadCallbackToUser:           callbackTypeAlias?
    public var pinMessageCallbackToUser:            callbackTypeAlias?
    public var unpinMessageCallbackToUser:          callbackTypeAlias?
    public var getContactNotSeenDurationCallbackToUser: callbackTypeAlias?
    public var getCurrentUserRolesCallbackToUser:       callbackTypeAlias?
    public var updateChatProfileCallbackToUser:         callbackTypeAlias?
    public var joinPublicThreadCallbackToUser:              callbackTypeAlias?
    public var isPublicThreadNameAvailableCallbackToUser:   callbackTypeAlias?
    public var statusPingCallbackToUser:            callbackTypeAlias?
    
    // Bot callBacks
    public var addBotCommandCallbackToUser: callbackTypeAlias?
    public var createBotCallbackToUser:     callbackTypeAlias?
    public var startBotCallbackToUser:      callbackTypeAlias?
    public var stopBotCallbackToUser:       callbackTypeAlias?
    
    
    
    // MARK: - create Async with the parameters
    
    public func CreateAsync() {
        asyncClient = Async(socketAddress:              socketAddress,
                            serverName:                 serverName,
                            deviceId:                   deviceId,
                            appId:                      nil,
                            peerId:                     nil,
                            messageTtl:                 messageTtl,
                            connectionRetryInterval:    connectionRetryInterval,
                            maxReconnectTimeInterval:   maxReconnectTimeInterval,
                            reconnectOnClose:           reconnectOnClose,
                            showDebuggingLogLevel:      debuggingLogLevel)
        asyncClient?.delegate = self
        asyncClient?.createSocket()
    }
    
    public func setGetUserInfoRetryCount(value: Int) {
        getUserInfoRetryCount = value
    }
    public func getGetUserInfoRetryCount() -> Int {
        return getUserInfoRetryCount
    }
    public func getGetUserInfoRetry() -> Int {
        return getUserInfoRetry
    }
    
}






