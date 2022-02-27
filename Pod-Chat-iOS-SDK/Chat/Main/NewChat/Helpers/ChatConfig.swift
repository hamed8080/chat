//
//  ChatConfig.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 1/31/21.
//

import Foundation
import FanapPodAsyncSDK

public struct ChatConfig {
    
	var socketAddress             		: String
	var ssoHost                   	    : String
	var platformHost	              	: String
	var fileServer	                    : String
	var podSpaceFileServerAddress 		: String  = "https://podspace.pod.ir"
	var serverName                	    : String
	var token                     	    : String
	var mapApiKey                 	    : String?
	var mapServer                 	    : String  =  "https://api.neshan.org/v1"
	var typeCode                  	    : String? = "default"
	var enableCache               	    : Bool    = false
	var cacheTimeStampInSec      		: Int     = (2 * 24) * (60 * 60)
	var msgPriority               	    : Int    = 1
	var msgTTL                    	    : Int    = 10
	var httpRequestTimeout        		: Int    = 20
	var actualTimingLog          		: Bool   = false
	var wsConnectionWaitTime      		: Double = 0.0
    var reconnectCount                  : Int    = 5
	var connectionRetryInterval   		: Int    = 5
	var connectionCheckTimeout    		: Int    = 20
	var messageTtl                	    : Int    = 10000
	var captureLogsOnSentry       		: Bool   = false
	var maxReconnectTimeInterval  		: Int    = 60
	var reconnectOnClose          		: Bool   = false
	var localImageCustomPath      		: URL?
	var localFileCustomPath       		: URL?
	var deviecLimitationSpaceMB   		: Int64  = 100
	var getDeviceIdFromToken      		: Bool   = false
	var showDebuggingLogLevel     		: LogLevel = LogLevel.error
    var deviceId                        : String? = nil
    var isDebuggingLogEnabled           : Bool    = false
    var isDebuggingAsyncEnable          : Bool    = false
    var enableNotificationLogObserver   : Bool    = false
    var useNewSDK                       : Bool    = false
    
    //Memberwise Initializer
    public init(socketAddress				: String,
                serverName					: String,
                token						: String,
                ssoHost						: String,
                platformHost				: String,
                fileServer					: String,
                podSpaceFileServerAddress	: String = "https://podspace.pod.ir",
                mapApiKey					: String? = nil,
                mapServer					: String = "https://api.neshan.org/v1",
                typeCode					: String? = "default",
                enableCache					: Bool = false,
                cacheTimeStampInSec			: Int = (2 * 24) * (60 * 60),
                msgPriority					: Int = 1,
                msgTTL						: Int = 10,
                httpRequestTimeout			: Int = 20,
                actualTimingLog				: Bool = false,
                wsConnectionWaitTime		: Double = 0.0,
                reconnectCount              : Int = 5,
                connectionRetryInterval		: Int = 5,
                connectionCheckTimeout		: Int = 20,
                messageTtl					: Int = 10000,
                captureLogsOnSentry			: Bool = false,
                maxReconnectTimeInterval	: Int = 60,
                reconnectOnClose			: Bool = false,
                localImageCustomPath		: URL? = nil,
                localFileCustomPath			: URL? = nil,
                deviecLimitationSpaceMB		: Int64 = 100,
                getDeviceIdFromToken		: Bool = false,
                showDebuggingLogLevel		: LogLevel = LogLevel.error,
                isDebuggingLogEnabled       : Bool = false,
                isDebuggingAsyncEnable      : Bool = false,
                enableNotificationLogObserver: Bool = false,
                useNewSDK                   : Bool = false
                ) {
        CacheFactory.write(cacheType: .DELETE_ALL_CONTACTS)
        CacheFactory.save()
		self.socketAddress 			    = socketAddress
		self.ssoHost 					= ssoHost
		self.platformHost 				= platformHost
		self.fileServer 				= fileServer
		self.serverName 				= serverName
		self.token 					    = token
		self.mapApiKey 				    = mapApiKey
		self.mapServer 				    = mapServer
		self.typeCode 				    = typeCode
		self.enableCache 				= enableCache
		self.cacheTimeStampInSec 		= cacheTimeStampInSec
		self.msgPriority 				= msgPriority
		self.msgTTL 					= msgTTL
		self.httpRequestTimeout 		= httpRequestTimeout
		self.actualTimingLog 			= actualTimingLog
		self.wsConnectionWaitTime 		= wsConnectionWaitTime
		self.connectionRetryInterval 	= connectionRetryInterval
		self.connectionCheckTimeout		= connectionCheckTimeout
		self.messageTtl 				= messageTtl
		self.captureLogsOnSentry 		= captureLogsOnSentry
		self.maxReconnectTimeInterval 	= maxReconnectTimeInterval
        self.reconnectCount             = reconnectCount
		self.reconnectOnClose 			= reconnectOnClose
		self.localImageCustomPath		= localImageCustomPath
		self.localFileCustomPath 		= localFileCustomPath
		self.deviecLimitationSpaceMB	= deviecLimitationSpaceMB
		self.getDeviceIdFromToken		= getDeviceIdFromToken
		self.showDebuggingLogLevel 		= showDebuggingLogLevel
        self.isDebuggingLogEnabled      = isDebuggingLogEnabled
        self.isDebuggingAsyncEnable     = isDebuggingAsyncEnable
        self.enableNotificationLogObserver = enableNotificationLogObserver
        self.useNewSDK                  = useNewSDK
    }
}
