//
//  CreateChatModel.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 1/31/21.
//

import Foundation
import FanapPodAsyncSDK

public struct CreateChatModel {
    
	var socketAddress             		: String   // Address of the Socket Server
	var ssoHost                   	    : String  = "http://172.16.110.76" // Address of the SSO Server (SERVICE_ADDRESSES.SSO_ADDRESS)
	var platformHost	              	: String  = "http://172.16.106.26:8080/hamsam" // Address of the platform (SERVICE_ADDRESSES.PLATFORM_ADDRESS)
	var fileServer	                    : String  = "http://172.16.106.26:8080/hamsam" // Address of the FileServer (SERVICE_ADDRESSES.FILESERVER_ADDRESS)
	var podSpaceFileServerAddress 		: String  = "https://podspace.pod.ir"
	var serverName                	    : String  // Name of the server that we had registered on
	var token                     	    : String  // Every user have to had a token (get it from SSO Server)
	var mapApiKey                 	    : String? = "8b77db18704aa646ee5aaea13e7370f4f88b9e8c"
	var mapServer                 	    : String  =  "https://api.neshan.org/v1"
	var typeCode                  	    : String? = "default"
	var enableCache               	    : Bool    = false
	var cacheTimeStampInSec      		: Int     = (2 * 24) * (60 * 60)
	var msgPriority               	    : Int    = 1
	var msgTTL                    	    : Int    = 10
	var httpRequestTimeout        		: Int    = 20
	var actualTimingLog          		: Bool   = false
	var wsConnectionWaitTime      		: Double = 0.0
	var connectionRetryInterval   		: Int    = 10000
	var connectionCheckTimeout    		: Int    = 10000
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
    
    //Memberwise Initializer
    public init(socketAddress				: String,
                serverName					: String,
                token						: String,
                ssoHost						: String = "http://172.16.110.76",
                platformHost				: String = "http://172.16.106.26:8080/hamsam",
                fileServer					: String = "http://172.16.106.26:8080/hamsam",
                podSpaceFileServerAddress	: String = "https://podspace.pod.ir",
                mapApiKey					: String? = "8b77db18704aa646ee5aaea13e7370f4f88b9e8c",
                mapServer					: String = "https://api.neshan.org/v1",
                typeCode					: String? = "default",
                enableCache					: Bool = false,
                cacheTimeStampInSec			: Int = (2 * 24) * (60 * 60),
                msgPriority					: Int = 1,
                msgTTL						: Int = 10,
                httpRequestTimeout			: Int = 20,
                actualTimingLog				: Bool = false,
                wsConnectionWaitTime		: Double = 0.0,
                connectionRetryInterval		: Int = 10000,
                connectionCheckTimeout		: Int = 10000,
                messageTtl					: Int = 10000,
                captureLogsOnSentry			: Bool = false,
                maxReconnectTimeInterval	: Int = 60,
                reconnectOnClose			: Bool = false,
                localImageCustomPath		: URL? = nil,
                localFileCustomPath			: URL? = nil,
                deviecLimitationSpaceMB		: Int64 = 100,
                getDeviceIdFromToken		: Bool = false,
                showDebuggingLogLevel		: LogLevel = LogLevel.error,
                isDebuggingLogEnabled       : Bool = false
                ) {

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
		self.reconnectOnClose 			= reconnectOnClose
		self.localImageCustomPath		= localImageCustomPath
		self.localFileCustomPath 		= localFileCustomPath
		self.deviecLimitationSpaceMB	= deviecLimitationSpaceMB
		self.getDeviceIdFromToken		= getDeviceIdFromToken
		self.showDebuggingLogLevel 		= showDebuggingLogLevel
        self.isDebuggingLogEnabled      = isDebuggingLogEnabled 
    }
}
