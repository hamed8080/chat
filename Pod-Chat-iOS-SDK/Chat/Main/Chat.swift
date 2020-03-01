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
import UIKit
//import Contacts


public class Chat {
    
    // MARK: - Chat initializer
    public init() {

    }
    
    public static let sharedInstance = Chat()
    
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
                                 maxReconnectTimeInterval:  Int?,
                                 reconnectOnClose:          Bool,
                                 localImageCustomPath:      URL?,
                                 localFileCustomPath:       URL?,
                                 deviecLimitationSpaceMB:   Int64?) {
        
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
        
        getDeviceIdWithToken { (deviceIdStr) in
            self.deviceId = deviceIdStr
            
            log.verbose("get deviceId successfully = \(self.deviceId ?? "error!!")", context: "Chat")
            
            DispatchQueue.main.async {
                self.CreateAsync()
            }
        }
        
        if checkIfDeviceHasFreeSpace(needSpaceInMB: self.deviecLimitationSpaceMB, turnOffTheCache: true) {
//            self.enableCache = false
        }
        
    }
    
    // the delegate property that the user class should make itself to be implment this delegat.
    // At first, the class sould confirm to ChatDelegates, and then implement the ChatDelegates methods
    public weak var delegate: ChatDelegates?
    
    // create cache instance to use cache...
    static let cacheDB = Cache()
    
    
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
    var chatFullStateObject: JSON = [:]
    
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
    
    var isTyping: (threadId: Int, uniqueId: String)? = (0, "")
    
    
    
    // MARK: - Timers
    
    var getUserInfoTimer: RepeatingTimer? {
        didSet {
            if isChatReady {
                self.getUserInfoTimer?.suspend()
            } else {
                self.getUserInfoTimer?.suspend()
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
        }
    }
    
    var lastReceivedMessageTime:    Date?
    var lastReceivedMessageTimer:   RepeatingTimer? {
        didSet {
            self.lastReceivedMessageTimer?.suspend()
            DispatchQueue.global().async {
                self.lastReceivedMessageTime = Date()
//                self.lastReceivedMessageTimeoutId = RepeatingTimer(timeInterval: (Double(self.chatPingMessageInterval) * 1.5))
                self.lastReceivedMessageTimer?.eventHandler = {
                    if let lastReceivedMessageTimeBanged = self.lastReceivedMessageTime {
                        let elapsed = Int(Date().timeIntervalSince(lastReceivedMessageTimeBanged))
                        if (elapsed >= self.connectionCheckTimeout) {
                            DispatchQueue.main.async {
                                self.asyncClient?.asyncReconnectSocket()
                            }
                            self.lastReceivedMessageTimer?.suspend()
                        }
                    }
                }
                self.lastReceivedMessageTimer?.resume()
            }
        }
    }
    
    var lastSentMessageTime:    Date?
    var lastSentMessageTimer:   RepeatingTimer? {
        didSet {
            /*
             * first of all, it will suspend the timer
             * then on the background thread it will run a timer
             * if the "isChatReady" = true (means chat is still connected)
             * and there are "chatPingMessageInterval" seconds passed from last message that sends to chat
             * it will send a ping message on the main thread
             *
             */
            self.lastSentMessageTimer?.suspend()
            DispatchQueue.global().async {
                self.lastSentMessageTime = Date()
//                self.lastSentMessageTimeoutId = RepeatingTimer(timeInterval: TimeInterval(self.chatPingMessageInterval))
                self.lastSentMessageTimer?.eventHandler = {
                    if let lastSendMessageTimeBanged = self.lastSentMessageTime {
                        let elapsed = Int(Date().timeIntervalSince(lastSendMessageTimeBanged))
                        if (elapsed >= self.chatPingMessageInterval) && (self.isChatReady == true) {
                            DispatchQueue.main.async {
                                self.ping()
                            }
                            self.lastSentMessageTimer?.suspend()
                        }
                    }
                }
                self.lastSentMessageTimer?.resume()
            }
        }
    }
    
    
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
    public var getHistoryCallbackToUser:            callbackTypeAlias?
    public var getMentionListCallbackToUser:        callbackTypeAlias?
    public var threadParticipantsCallbackToUser:    callbackTypeAlias?
    public var createThreadCallbackToUser:          callbackTypeAlias?
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
    public var blockUserCallbackToUser:             callbackTypeAlias?
    public var unblockUserCallbackToUser:           callbackTypeAlias?
    public var getBlockedUserCallbackToUser:        callbackTypeAlias?
    public var leaveThreadCallbackToUser:           callbackTypeAlias?
    public var spamPvThreadCallbackToUser:          callbackTypeAlias?
    public var getMessageSeenListCallbackToUser:    callbackTypeAlias?
    public var getMessageDeliverListCallbackToUser: callbackTypeAlias?
    public var clearHistoryCallbackToUser:          callbackTypeAlias?
    public var getAdminListCallbackToUser:          callbackTypeAlias?
    public var setRoleToUserCallbackToUser:         callbackTypeAlias?
    public var removeRoleFromUserCallbackToUser:    callbackTypeAlias?
    public var pinThreadCallbackToUser:             callbackTypeAlias?
    public var unpinThreadCallbackToUser:           callbackTypeAlias?
    public var pinMessageCallbackToUser:            callbackTypeAlias?
    public var unpinMessageCallbackToUser:          callbackTypeAlias?
    public var getNotSeenDurationCallbackToUser:    callbackTypeAlias?
    public var getCurrentUserRolesCallbackToUser:   callbackTypeAlias?
    public var setProfileCallbackToUser:            callbackTypeAlias?
    
    
    
    // MARK: - create Async with the parameters
    
    public func CreateAsync() {
        if let dId = deviceId {
            asyncClient = Async(socketAddress:              socketAddress,
                                serverName:                 serverName,
                                deviceId:                   dId,
                                appId:                      nil,
                                peerId:                     nil,
                                messageTtl:                 messageTtl,
                                connectionRetryInterval:    connectionRetryInterval,
                                maxReconnectTimeInterval:   maxReconnectTimeInterval,
                                reconnectOnClose:           reconnectOnClose)
            asyncClient?.delegate = self
            asyncClient?.createSocket()
        }
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






